#!/bin/bash
latest_backup=$(wal-g backup-list | tail -n 1)
wal-g backup-fetch /var/lib/postgresql/data "$latest_backup"