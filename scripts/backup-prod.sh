#!/bin/bash
# Database backup script for production environment
# Runs via cron in backup container every 6 hours

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
BACKUP_FILE="space_adventures_prod_${TIMESTAMP}.sql"
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}

echo "[$(date)] Starting backup: ${BACKUP_FILE}"

# PostgreSQL backup
pg_dump -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -d ${POSTGRES_DB} > "${BACKUP_DIR}/${BACKUP_FILE}"

if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: pg_dump failed"
    exit 1
fi

# Compress
gzip "${BACKUP_DIR}/${BACKUP_FILE}"

if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Compression failed"
    exit 1
fi

BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}.gz" | cut -f1)
echo "[$(date)] Backup created: ${BACKUP_FILE}.gz (Size: ${BACKUP_SIZE})"

# Upload to S3 if configured
if [ -n "${S3_BUCKET}" ]; then
    echo "[$(date)] Uploading to S3: s3://${S3_BUCKET}/backups/${BACKUP_FILE}.gz"

    aws s3 cp "${BACKUP_DIR}/${BACKUP_FILE}.gz" "s3://${S3_BUCKET}/backups/${BACKUP_FILE}.gz" \
        --storage-class STANDARD_IA

    if [ $? -eq 0 ]; then
        echo "[$(date)] Successfully uploaded to S3"
    else
        echo "[$(date)] ERROR: S3 upload failed"
        # Continue - keep local backup even if S3 fails
    fi

    # Clean up old S3 backups
    echo "[$(date)] Cleaning up old S3 backups (keeping ${RETENTION_DAYS} days)"

    aws s3 ls "s3://${S3_BUCKET}/backups/" | while read -r line; do
        fileDate=$(echo $line | awk '{print $1" "$2}')
        fileName=$(echo $line | awk '{print $4}')

        # Calculate age in days
        fileEpoch=$(date -d "$fileDate" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$fileDate" +%s)
        currentEpoch=$(date +%s)
        age=$(( (currentEpoch - fileEpoch) / 86400 ))

        if [ $age -gt $RETENTION_DAYS ]; then
            echo "[$(date)] Deleting old backup: ${fileName} (${age} days old)"
            aws s3 rm "s3://${S3_BUCKET}/backups/${fileName}"
        fi
    done
fi

# Clean up old local backups (keep last 7 days)
echo "[$(date)] Cleaning up old local backups (keeping 7 days)"
find ${BACKUP_DIR} -name "*.sql.gz" -mtime +7 -delete

# Verify backup integrity
echo "[$(date)] Verifying backup integrity"
gunzip -t "${BACKUP_DIR}/${BACKUP_FILE}.gz"

if [ $? -eq 0 ]; then
    echo "[$(date)] Backup verification successful"
else
    echo "[$(date)] ERROR: Backup verification failed!"
    exit 1
fi

# List current backups
echo "[$(date)] Current local backups:"
ls -lh ${BACKUP_DIR}/*.sql.gz 2>/dev/null || echo "No local backups found"

echo "[$(date)] Backup process completed successfully"
