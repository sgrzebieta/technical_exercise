#!/bin/bash
export GCS_BUCKET=${bucket_name}
export GCS_KEY_FILE_PATH="/opt/mongodb/sa.json"
echo "10 0 * * * /opt/mongodb/backup.sh" >> crontab