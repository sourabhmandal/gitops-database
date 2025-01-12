-- Delete the user if it already exists
DO $$
BEGIN
   IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'replicator') THEN
      EXECUTE 'DROP ROLE replicator';
   END IF;
END
$$;

CREATE USER replicator REPLICATION PASSWORD '${POSTGRES_REPLICATION_PASSWORD}';

-- Create the schema if it doesn't already exist
CREATE SCHEMA IF NOT EXISTS supareel;

-- Create the users table if it doesn't already exist
CREATE TABLE IF NOT EXISTS supareel.users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert data into the users table
-- Use ON CONFLICT to avoid errors if duplicate data is inserted
INSERT INTO supareel.users (name, email) 
VALUES 
    ('Alice', 'alice@example.com'),
    ('Bob', 'bob@example.com'),
    ('Charlie', 'charlie@example.com')
ON CONFLICT (email) DO NOTHING;