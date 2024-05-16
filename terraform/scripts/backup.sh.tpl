#!/bin/bash
export GCS_BUCKET=${bucket_name}
echo "30 0 * * * /opt/mongodb/backup.sh" >> crontab