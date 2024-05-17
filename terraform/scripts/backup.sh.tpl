#!/bin/bash
export GCS_BUCKET=${bucket_name}
echo "10 0 * * * /opt/mongodb/backup.sh" >> crontab