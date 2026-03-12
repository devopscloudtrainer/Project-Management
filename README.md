aws rds describe-db-proxy-targets   --db-proxy-name rds-postgres-dev-dev-postgres-proxy   --region ap-south-1   --query "Targets[*].{Status:TargetHealth.State,Reason:TargetHealth.Reason,Description:TargetHealth.Description}"

aws secretsmanager get-secret-value   --secret-id "rds-postgres-dev/dev/rds/credentials"   --query SecretString   --output text   --region ap-south-1 | python3 -m json.tool


psql -h rds-postgres-dev-dev-postgres-proxy.proxy-c9y4sim2iwqt.ap-south-1.rds.amazonaws.com \
      -U dbadmin \
      -d appdb \
      -p 5432
Password for user dbadmin: 
psql (15.16, server 15.17)
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_128_GCM_SHA256, compression: off)
Type "help" for help.
appdb=> 
appdb=> 


~ $ psql 'host=rds-postgres-dev-dev-postgres.c9y4sim2iwqt.ap-south-1.rds.amazonaws.com port=5432 user=dbadmin dbname=appdb sslrootcert=/certs/global-bundle.pem sslmode=verify-full'
Password for user dbadmin: 
psql (15.16, server 15.17)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, compression: off)
Type "help" for help.
appdb=> 
appdb=> 
appdb=>

🛠️ Useful psql Commands
Database Info
sql-- Check connection details
\conninfo

-- PostgreSQL version
SELECT version();

-- Current database & user
SELECT current_database(), current_user;
Explore
sql-- List all databases
\l

-- List tables (none yet)
\dt

-- List schemas
\dn
Create Your First Table
sql-- Create a test table
CREATE TABLE users (
  id        SERIAL PRIMARY KEY,
  name      VARCHAR(100) NOT NULL,
  email     VARCHAR(150) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample data
INSERT INTO users (name, email) VALUES
  ('Alice', 'alice@example.com'),
  ('Bob',   'bob@example.com');

-- Query it
SELECT * FROM users;
Admin Checks
sql-- Check active connections
SELECT pid, usename, application_name, state, query_start
FROM pg_stat_activity
WHERE datname = 'appdb';

-- Check database size
SELECT pg_size_pretty(pg_database_size('appdb'));

-- Check all extensions available
SELECT name, default_version FROM pg_available_extensions ORDER BY name;

🚪 Exit psql
bash\q

