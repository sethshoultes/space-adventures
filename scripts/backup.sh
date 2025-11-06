#!/bin/bash
# Database backup script for staging environment
# Runs via cron in backup container

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
BACKUP_FILE="space_adventures_staging_${TIMESTAMP}.sql"

echo "Starting backup: ${BACKUP_FILE}"

# PostgreSQL backup
pg_dump -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -d ${POSTGRES_DB} > "${BACKUP_DIR}/${BACKUP_FILE}"

# Compress
gzip "${BACKUP_DIR}/${BACKUP_FILE}"

# Clean up old backups (keep last 7 days)
find ${BACKUP_DIR} -name "*.sql.gz" -mtime +7 -delete

echo "Backup completed: ${BACKUP_FILE}.gz"
echo "Size: $(du -h ${BACKUP_DIR}/${BACKUP_FILE}.gz | cut -f1)"
