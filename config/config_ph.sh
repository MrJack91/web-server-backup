# BEGIN CONFIGURATION ==========================================================

BACKUP_DIR="/home/u958489228/backups/"  # The directory in which you want backups placed
DUMP_MYSQL=true
TAR_SITES=true
SYNC="none" # Either 's3sync', 'rsync', or 'none'
KEEP_MYSQL="5" # How many days worth of mysql dumps to keep
KEEP_SITES="5" # How many days worth of site tarballs to keep

MYSQL_HOST="127.0.0.1"
MYSQL_USER="u958489228_phweb"
MYSQL_PASS="gMzABL3hE7RJqurXtPug"
MYSQL_BACKUP_DIR="$BACKUP_DIR/mysql/"
MYSQL_DATABASE="u958489228_t3ph" # which database to backup, if this is empty all databases will be back uped

SITES_DIR="/home/u958489228/public_html/"
SITES_BACKUP_DIR="$BACKUP_DIR/sites/"
SITES_EXCLUDES = "typo3temp"


# See s3sync info in README
S3SYNC_PATH="/usr/local/s3sync/s3sync.rb"
S3_BUCKET="my-fancy-bucket"
AWS_ACCESS_KEY_ID="YourAWSAccessKey" # Log in to your Amazon AWS account to get this
AWS_SECRET_ACCESS_KEY="YourAWSSecretAccessKey" # Log in to your Amazon AWS account to get this
USE_SSL="true"
SSL_CERT_DIR="/etc/ssl/certs" # Where your Cert Authority keys live; for verification
SSL_CERT_FILE="" # If you have just one PEM file for CA verification

# If you don't want to use S3, you can rsync to another server
RSYNC_USER="user"
RSYNC_SERVER="other.server.com"
RSYNC_DIR="web_site_backups"
RSYNC_PORT="22" # Change this if you've customized the SSH port of your backup system

# You probably won't have to change these
#THE_DATE="$(date '+%Y-%m-%d')"
THE_DATE="$(date '+%Y-%m-%d-%H-%M-%S')"

MYSQL_PATH="$(which mysql)"
MYSQLDUMP_PATH="$(which mysqldump)"
FIND_PATH="$(which find)"
TAR_PATH="$(which tar)"
RSYNC_PATH="$(which rsync)"

# END CONFIGURATION ============================================================
