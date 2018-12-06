FROM debian:stretch-slim
LABEL description="MongoDB cron backup to Google Cloud Storage (GCE)"
LABEL maintainer="todd.mannherz@gmail.com"

RUN apt-get update && \
    apt-get install -qqy cron curl python gnupg2

# Install MongoDB tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list && \
    apt-get update && \
    apt-get install -qqy mongodb-org-tools

# Install gsutil
RUN curl -s -O https://storage.googleapis.com/pub/gsutil.tar.gz && \
    tar xfz gsutil.tar.gz -C $HOME && \
    chmod +x /root/gsutil/gsutil && \
    ln -s /root/gsutil/gsutil /usr/local/bin/gsutil && \
    rm gsutil.tar.gz    

# Add the backup script
ENV CRON_SCHEDULE "0 6 * * *"
RUN mkdir /backup
COPY db_backup.sh /backup/
COPY db_restore.sh /backup/
RUN chmod +x /backup/db_backup.sh
RUN chmod +x /backup/db_restore.sh

# Docker logging from cron runs
RUN ln -sf /proc/1/fd/1 /var/log/cron.log

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
