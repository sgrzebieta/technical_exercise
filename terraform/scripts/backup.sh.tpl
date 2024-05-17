#!/bin/bash
export GCS_BUCKET=${bucket_name}
export GCS_KEY_FILE_PATH="/opt/mongodb/sa.json"
(crontab -l ; echo "*/10 * * * * cd /opt/mongodb && /backup.sh >> /var/log/mongo_backup.log 2>&1") | crontab -