#!/bin/bash

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h localhost -p 5432; do
  sleep 2
done


# Create a backup
BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S)"
wal-g backup-push /var/lib/postgresql/data
echo "Backup completed: $BACKUP_NAME"


# Backup loop
while true; do
  echo "Starting backup at $(date)..."
  wal-g backup-push /var/lib/postgresql/data
  if [ $? -eq 0 ]; then
    echo "Backup completed successfully at $(date)."
  else
    echo "Backup failed at $(date). Retrying in 5 minutes..."
  fi
  sleep 30 # Wait 30 seconds before the next backup
done

