#!/bin/bash
set -e

if [ -z "$MONGO_HOST" ]; then
    echo "MONGO_HOST must be specified."
    exit 1
fi
if [ -z "$MONGO_DATABASE" ]; then
    echo "MONGO_DATABASE must be specified."
    exit 1
fi
if [ -z "$GS_BACKUP_BUCKET" ]; then
    echo "GS_BACKUP_BUCKET must be specified."
    exit 1
fi

gs_project_id="$GS_PROJECT_ID"
gs_service_client_id="$GS_SERVICE_EMAIL"

# Create boto config file
cat <<EOF > /etc/boto.cfg
[Credentials]
gs_service_client_id = $gs_service_client_id
gs_service_key_file = /backup/service-account.json
[Boto]
https_validate_certificates = True
[GSUtil]
content_language = en
default_api_version = 2
default_project_id = $gs_project_id
EOF

# support docker-compose secret
if [ -f /run/secrets/service_account ]; then
    cp /run/secrets/service_account /backup/service-account.json
fi

# Create crontab
mkdir -p /etc/cron.d
TASK=/etc/cron.d/task
touch $TASK
chmod 0644 $TASK
COMMAND="$CRON_SCHEDULE root /backup/db_backup.sh >> /var/log/cron.log 2>&1"
echo "$COMMAND" >> $TASK
echo "# End" >> $TASK

if [ "$1" == "" ]; then
    # Expose env vars to the cron
    env | sed -r "s/'/\\\'/gm" | sed -r "s/^([^=]+=)(.*)\$/\1'\2'/gm" > /etc/environment
    echo "Starting the cron service."
    cron -f
fi

exec "$@"
