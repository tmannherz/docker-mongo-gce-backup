# MongoDB backup to Google Cloud Storage

A docker image to back up a MongoDB instance to Google Cloud Storage.

The container runs a cron that backs up the database using `mongodump` in a gzipped archive (`--gzip --archive`) at 6am UTC before pushing to GS.

## Environment Variables

* `MONGO_HOST` - Host of MongoDB instance
* `MONGO_DATABASE` - DB to backup
* `GS_PROJECT_ID` - GCE project ID
* `GS_SERVICE_EMAIL` - Email of service account to use
* `GS_BACKUP_BUCKET` - Cloud storage bucket to push backup to

The backup script expects a service account auth JSON file in `/backup/service-account.json`.

## Run

```
docker run --name backup \
  -v /your/service-account.json:/backup/service-account.json:ro \
  -e MONGO_HOST=db \
  -e MONGO_DATABASE=documents \
  -e GS_PROJECT_ID=my-project \
  -e GS_SERVICE_EMAIL=email@proj.iam.gserviceaccount.com \
  -e GS_BACKUP_BUCKET=my-bucket \
  --network default \
  --link service_db:db \
  tmannherz/docker-mongo-gce-backup
```

## Use with `docker-compose`

```$yaml
services:
  db:
    image: mongo
    restart: always
    volumes:
       - db_data:/data/db

  db_backup:
    image: tmannherz/docker-mongo-gce-backup
    depends_on:
      - db
    restart: always
    environment:
      MONGO_HOST: db
      MONGO_DATABASE: documents
      GS_PROJECT_ID: my-project
      GS_SERVICE_EMAIL: emails@proj.iam.gserviceaccount.com
      GS_BACKUP_BUCKET: my-bucket
    secrets:
      - service_account

secrets:
  service_account:
    file: service_account.json      
```
