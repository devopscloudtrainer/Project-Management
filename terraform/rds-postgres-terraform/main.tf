terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC Data Source (uses default or specify your VPC) ---
data "aws_vpc" "selected" {
  id = var.vpc_id
}


# --- Security Group for RDS ---
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from app layer"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
  }
}

# --- Call the RDS Module ---
module "rds_postgres" {
  source = "./modules/rds"

  # Identification
  identifier      = "${var.project_name}-${var.environment}-postgres"
  project_name    = var.project_name
  environment     = var.environment

  # Engine
  engine_version  = var.postgres_version
  instance_class  = var.db_instance_class

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Credentials
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  # Network
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  # Backup & Maintenance
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Monitoring
  monitoring_interval = 60
  enable_insights     = true

  # Misc
  deletion_protection      = var.deletion_protection
  skip_final_snapshot      = var.environment == "dev" ? true : false
  final_snapshot_identifier = "${var.project_name}-${var.environment}-final-snapshot"
}

# --- RDS Proxy Module ---
module "rds_proxy" {
  source = "./modules/rds-proxy"

  identifier   = "${var.project_name}-${var.environment}-postgres"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_id   = var.vpc_id
  vpc_cidr = data.aws_vpc.selected.cidr_block

  subnet_ids             = var.subnet_ids
  db_instance_identifier = module.rds_postgres.db_instance_identifier
  db_secret_arn          = aws_secretsmanager_secret.db_credentials.arn

  # Connection pool tuning
  idle_client_timeout          = 1800
  max_connections_percent      = 100
  max_idle_connections_percent = 50
  connection_borrow_timeout    = 120

  depends_on = [
    module.rds_postgres,
    aws_secretsmanager_secret_version.db_credentials
  ]
}
