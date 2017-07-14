#!/bin/bash
# MongoDB backup to GCE
echo "--------------------------------"

# variables
BACKUP_DIR=/backup
DB_HOST="$MONGO_HOST"
DB_NAME="$MONGO_DATABASE"
BUCKET_NAME="$GS_BACKUP_BUCKET"
DATE=$(date +"%Y-%m-%d")
FILE=$DB_NAME_$DATE.archive.gz

cd $BACKUP_DIR

if [ -z "$DB_HOST" ]; then
    echo "DB_HOST is empty."
    exit 1
fi
if [ -z "$DB_NAME" ]; then
    echo "DB_NAME is empty."
    exit 1
fi
if [ -z "$BUCKET_NAME" ]; then
    echo "BUCKET_NAME is empty."
    exit 1
fi

echo "Creating the MongoDB archive"
mongodump -h "$DB_HOST" -d "$DB_NAME" --gzip --archive="$FILE"

# push to GCE
echo "Copying $BACKUP_DIR/$FILE to gs://$BUCKET_NAME/mongo/$FILE"
/root/gsutil/gsutil cp $FILE gs://"$BUCKET_NAME"/mongo/$FILE 2>&1

# remove all old backups from the server over 3 days old
echo "Removing old backups."
find ./ -name "*.archive.gz" -mtime +2 -exec rm {} +

echo "Backup complete."
