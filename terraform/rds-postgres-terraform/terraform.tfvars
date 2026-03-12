aws_region   = "ap-south-1"
vpc_id       = "vpc-07f5924f332c81f39"
project_name = "rds-postgres-dev"
environment  = "dev"

postgres_version = "15.17"
db_instance_class = "db.t3.micro"

allocated_storage     = 20
max_allocated_storage = 100

db_name     = "appdb"
db_username = "dbadmin"

multi_az                = false
backup_retention_period = 7
deletion_protection     = false

subnet_ids = [
  "subnet-0ecb5c7c1eb448c70",   # ap-south-1b
  "subnet-055bb7e7faf739f39",   # ap-south-1c
  "subnet-0d783d65d50efbaf4"    # ap-south-1a
]
