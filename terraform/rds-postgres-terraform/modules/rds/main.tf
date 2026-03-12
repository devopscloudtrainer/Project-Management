# --- DB Subnet Group ---
resource "aws_db_subnet_group" "this" {
  name        = "${var.identifier}-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for ${var.identifier}"

  tags = {
    Name        = "${var.identifier}-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# --- Parameter Group ---
resource "aws_db_parameter_group" "this" {
  name        = "${var.identifier}-pg15"
  family      = "postgres${split(".", var.engine_version)[0]}"
  description = "Custom parameter group for ${var.identifier}"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"  # Log queries > 1 second
  }

  tags = {
    Name        = "${var.identifier}-param-group"
    Environment = var.environment
  }
}

# --- IAM Role for Enhanced Monitoring ---
resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name = "${var.identifier}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# --- RDS PostgreSQL Instance ---
resource "aws_db_instance" "this" {
  # Identity
  identifier = var.identifier

  # Engine
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted

  # Credentials
  db_name  = var.db_name
  username = var.username
  password = var.password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  # Configuration
  parameter_group_name = aws_db_parameter_group.this.name

  # Backup
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = true
  delete_automated_backups  = false

  # Monitoring
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
  performance_insights_enabled    = var.enable_insights
  performance_insights_retention_period = var.enable_insights ? 7 : null

  # Misc
  auto_minor_version_upgrade  = true
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : var.final_snapshot_identifier

  tags = {
    Name        = var.identifier
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
