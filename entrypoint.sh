#!/bin/bash
set -e

gs_project_id="$GS_PROJECT_ID"
gs_service_client_id="$GS_SERVICE_EMAIL"

# Create boto config file
cat <<EOF > /etc/boto.cfg
[Credentials]
gs_service_client_id = $gs_service_client_id
gs_service_key_file = /run/secrets/gcloud_service_account
[Boto]
https_validate_certificates = True
[GSUtil]
content_language = en
default_api_version = 2
default_project_id = $gs_project_id
EOF

# Expose env vars to the cron
env | sed -r "s/'/\\\'/gm" | sed -r "s/^([^=]+=)(.*)\$/\1'\2'/gm" > /etc/environment

echo "Starting the cron service."
cron -f
