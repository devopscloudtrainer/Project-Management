output "proxy_endpoint" {
  description = "RDS Proxy endpoint (use this instead of direct RDS endpoint)"
  value       = aws_db_proxy.this.endpoint
}

output "proxy_arn" {
  description = "RDS Proxy ARN"
  value       = aws_db_proxy.this.arn
}

output "proxy_name" {
  description = "RDS Proxy name"
  value       = aws_db_proxy.this.name
}

output "proxy_security_group_id" {
  description = "Security group ID attached to the proxy"
  value       = aws_security_group.rds_proxy.id
}
