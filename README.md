# MongoDB backup to Google Cloud Storage

A docker image to back up a MongoDB instance to Google Cloud Storage.

The container runs a cron that backs up the database at 6am UTC before pushing to GS.

## Environment Variables

* `MONGO_HOST` - Host of MongoDB instance
* `MONGO_DATABASE` - DB to backup
* `GS_PROJECT_ID` - GCE project ID
* `GS_SERVICE_EMAIL` - Email of service account to use
* `GS_BACKUP_BUCKET` - Cloud storage bucket to push backup to

The backup script expects a service account auth JSON file in `/run/secrets/gcloud_service_account`.

## Use with `docker-compose`

```$yaml
services:
  db:
    image: mongo
    restart: always
    volumes:
       - db_data:/data/db

  db_backup:
    image: tmannherz/mongo-gce-backup
    depends_on:
      - db
    restart: always
    environment:
      MONGO_HOST: db
      GS_PROJECT_ID: my-project
      GS_BACKUP_BUCKET: my-bucket
      GS_SERVICE_EMAIL: emails@proj.iam.gserviceaccount.com
    volumes:
       - db_data:/data/db
    secrets:
      - gcloud_service_account
secrets:
  gcloud_service_account:
    file: gcloud_service_account.json      
```
