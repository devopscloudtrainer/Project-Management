# --- Generate a random password ---
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"  # RDS-safe special chars
}

# --- Store password in Secrets Manager ---
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/${var.environment}/rds/credentials"
  description             = "RDS PostgreSQL credentials for ${var.project_name} ${var.environment}"
  recovery_window_in_days = var.environment == "prod" ? 30 : 0  # instant delete in dev

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-credentials"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# --- Store the actual secret value as JSON ---
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    dbname   = var.db_name
    engine   = "postgres"
    port     = 5432
    host     = module.rds_postgres.db_endpoint
  })

  # Wait for RDS to be created first so we can include the host
  depends_on = [module.rds_postgres]
}
