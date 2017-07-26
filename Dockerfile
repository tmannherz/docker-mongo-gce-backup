FROM debian:jessie-slim
LABEL description="MongoDB cron backup to Google Cloud Storage (GCE)"
LABEL maintainer="todd.mannherz@gmail.com"

RUN apt-get update && \ 
    apt-get install -qqy cron curl python

# Install MongoDB tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 && \
    echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list && \
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
RUN chmod +x /backup/db_backup.sh

# Docker logging from cron runs
RUN ln -sf /proc/1/fd/1 /var/log/cron.log

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
