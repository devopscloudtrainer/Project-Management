# --- IAM Role for RDS Proxy ---
resource "aws_iam_role" "rds_proxy" {
  name = "${var.identifier}-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "rds.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "${var.identifier}-proxy-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# --- IAM Policy: allow proxy to read secret from Secrets Manager ---
resource "aws_iam_role_policy" "rds_proxy_secrets" {
  name = "${var.identifier}-proxy-secrets-policy"
  role = aws_iam_role.rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [var.db_secret_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = ["*"]
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# --- Security Group for RDS Proxy ---
resource "aws_security_group" "rds_proxy" {
  name        = "${var.identifier}-proxy-sg"
  description = "Security group for RDS Proxy"
  vpc_id      = var.vpc_id

  # Allow inbound PostgreSQL from app layer / VPC
  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow outbound to RDS instance
  egress {
    description = "PostgreSQL to RDS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${var.identifier}-proxy-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# --- RDS Proxy ---
resource "aws_db_proxy" "this" {
  name                   = "${var.identifier}-proxy"
  debug_logging          = var.debug_logging
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = var.idle_client_timeout
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = [aws_security_group.rds_proxy.id]
  vpc_subnet_ids         = var.subnet_ids

  auth {
    auth_scheme               = "SECRETS"
    description               = "RDS Proxy auth via Secrets Manager"
    iam_auth                  = var.iam_auth
    secret_arn                = var.db_secret_arn
  }

  tags = {
    Name        = "${var.identifier}-proxy"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# --- RDS Proxy Default Target Group ---
resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    connection_borrow_timeout    = var.connection_borrow_timeout
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
  }
}

# --- RDS Proxy Target (points to RDS instance) ---
resource "aws_db_proxy_target" "this" {
  db_instance_identifier = var.db_instance_identifier
  db_proxy_name          = aws_db_proxy.this.name
  target_group_name      = aws_db_proxy_default_target_group.this.name
}
