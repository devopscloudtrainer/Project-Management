output "rds_endpoint" {
  description = "Direct RDS endpoint (use proxy instead in apps)"
  value       = module.rds_postgres.db_endpoint
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = module.rds_postgres.db_port
}

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = module.rds_postgres.db_instance_id
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = module.rds_postgres.db_arn
}

output "db_name" {
  description = "Database name"
  value       = module.rds_postgres.db_name
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secret_name" {
  description = "Name to retrieve secret from CLI"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "proxy_endpoint" {
  description = "RDS Proxy endpoint — use this in your app connection string"
  value       = module.rds_proxy.proxy_endpoint
}

output "proxy_arn" {
  description = "RDS Proxy ARN"
  value       = module.rds_proxy.proxy_arn
}

output "proxy_name" {
  description = "RDS Proxy name"
  value       = module.rds_proxy.proxy_name
}
