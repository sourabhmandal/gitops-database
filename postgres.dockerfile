FROM golang:1.22-alpine AS builder

# Install dependencies for building WAL-G
RUN apk add --no-cache git build-base
RUN git clone https://github.com/wal-g/wal-g.git
WORKDIR /go/wal-g
RUN make install && make deps && make pg_build

FROM postgres:17-alpine

# Install necessary packages including postgresql-contrib
RUN apk add --no-cache \
  ca-certificates \
  lzo \
  bash \
  git \
  postgresql-contrib \
  postgresql-dev

# Install WAL-G
COPY --from=builder /go/wal-g/main/pg/wal-g /usr/local/bin/wal-g
RUN chmod +x /usr/local/bin/wal-g

# Create backup scripts directory and copy the backup scripts
RUN mkdir -p /backup-scripts
COPY backup-scripts/* /backup-scripts/
RUN chmod +x /backup-scripts/backup.sh /backup-scripts/restore.sh

# Ensure proper permissions for backup files and directories
RUN mkdir -p /var/lib/postgresql/wal-g && \
  chown -R postgres:postgres /var/lib/postgresql/wal-g && \
  chmod 750 /var/lib/postgresql/wal-g

# Copy and use custom postgresql.conf and pg_hba.conf files
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# Add initialization SQL for replication user
COPY initdb.sql /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/initdb.sql

USER postgres

# Start PostgreSQL with the custom configuration
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]