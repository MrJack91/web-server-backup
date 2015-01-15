#!/bin/bash

source ~/web-server-backup.conf

# Announce the backup time
echo "Backup Started: $(date)"

# Create the backup dirs if they don't exist
if [[ ! -d $BACKUP_DIR ]]
  then
  mkdir -p "$BACKUP_DIR"
fi
if [[ ! -d $MYSQL_BACKUP_DIR ]]
  then
  mkdir -p "$MYSQL_BACKUP_DIR"
fi
if [[ ! -d $SITES_BACKUP_DIR ]]
  then
  mkdir -p "$SITES_BACKUP_DIR"
fi

if [ "$DUMP_MYSQL" = "true" ]
  then

  # Get a list of mysql databases and dump them one by one
  echo "------------------------------------"
  if [ $MYSQL_DATABASE ]
    then
    db=$MYSQL_DATABASE
    echo "Dumping: $db..."
    if [ -z  "$MYSQL_PASS" ]
      then
      $MYSQLDUMP_PATH --opt --skip-add-locks -h $MYSQL_HOST -u$MYSQL_USER $db | gzip > $MYSQL_BACKUP_DIR$db\_$THE_DATE.sql.gz
    else
      $MYSQLDUMP_PATH --opt --skip-add-locks -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS $db | gzip > $MYSQL_BACKUP_DIR$db\_$THE_DATE.sql.gz
    fi
  else
    DBS="$($MYSQL_PATH -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS -Bse 'show databases')"
    for db in $DBS
    do
      if [[ $db != "information_schema" && $db != "mysql" && $db != "performance_schema" ]]
        then
        echo "Dumping: $db..."
        if [ -z  "$MYSQL_PASS" ]
          then
          $MYSQLDUMP_PATH --opt --skip-add-locks -h $MYSQL_HOST -u$MYSQL_USER $db | gzip > $MYSQL_BACKUP_DIR$db\_$THE_DATE.sql.gz
        else
          $MYSQLDUMP_PATH --opt --skip-add-locks -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS $db | gzip > $MYSQL_BACKUP_DIR$db\_$THE_DATE.sql.gz
        fi
      fi
    done
  fi

  # Delete old dumps
  echo "------------------------------------"
  echo "Deleting old backups..."
  # List dumps to be deleted to stdout (for report)
  $FIND_PATH $MYSQL_BACKUP_DIR*.sql.gz -mtime +$KEEP_MYSQL
  # Delete dumps older than specified number of days
  $FIND_PATH $MYSQL_BACKUP_DIR*.sql.gz -mtime +$KEEP_MYSQL -exec rm {} +

fi

if [ "$TAR_SITES" == "true" ]
  then

  # Get a list of files in the sites directory and tar them one by one
  echo "------------------------------------"
  cd $SITES_DIR

  echo "Archiving $SITES_DIR..."
  $TAR_PATH --exclude=$SITES_EXCLUDES -C $SITES_DIR -czf $SITES_BACKUP_DIR/$THE_DATE.tgz .

  #every folder in seperate folder
  #for d in *
  #do
  #  echo "Archiving $d..."
  #  $TAR_PATH --exclude="*/log" -C $SITES_DIR -czf $SITES_BACKUP_DIR/$d\_$THE_DATE.tgz $d
  #done

  # Delete old site backups
  echo "------------------------------------"
  echo "Deleting old backups..."
  # List files to be deleted to stdout (for report)
  $FIND_PATH $SITES_BACKUP_DIR*.tgz -mtime +$KEEP_SITES
  # Delete files older than specified number of days
  $FIND_PATH $SITES_BACKUP_DIR*.tgz -mtime +$KEEP_SITES -exec rm {} +

fi

# Rsync everything with another server
if [[ "$SYNC" == "rsync" ]]
  then
  echo "------------------------------------"
  echo "Sending backups to backup server..."
  $RSYNC_PATH --del -vaze "ssh -p $RSYNC_PORT" $BACKUP_DIR/ $RSYNC_USER@$RSYNC_SERVER:$RSYNC_DIR

  # OR s3sync everything with Amazon S3
elif [[ "$SYNC" == "s3sync" ]]
  then
  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export SSL_CERT_DIR
  export SSL_CERT_FILE
  if [[ $USE_SSL == "true" ]]
    then
    SSL_OPTION=' --ssl '
  else
    SSL_OPTION=''
  fi
  echo "------------------------------------"
  echo "Sending backups to s3..."
  $S3SYNC_PATH --delete -v $SSL_OPTION -r $BACKUP_DIR/ $S3_BUCKET:backups
fi

# Announce the completion time
echo "------------------------------------"
echo "Backup Completed: $(date)"
