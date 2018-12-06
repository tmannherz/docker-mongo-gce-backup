#!/bin/bash
# MongoDB restore from GCS
set -e
echo "--------------------------------"

# variables
BACKUP_DIR=/backup
DB_HOST="$MONGO_HOST"
BUCKET_NAME="$GS_BACKUP_BUCKET"
DATE=$(date +"%Y-%m-%d")
FILE=$1.archive.gz

cd $BACKUP_DIR

if [ -z "$DB_HOST" ]; then
    echo "DB_HOST is empty."
    exit 1
fi
if [ -z "$BUCKET_NAME" ]; then
    echo "BUCKET_NAME is empty."
    exit 1
fi

# pull from GCS
echo "Copying gs://$BUCKET_NAME/mongo/$FILE" to $BACKUP_DIR/$FILE
/root/gsutil/gsutil cp gs://"$BUCKET_NAME"/mongo/$FILE $FILE 2>&1

echo "Restoring the MongoDB archive"
mongorestore -h "$DB_HOST" --gzip --archive="$FILE"

echo "Restore complete."
