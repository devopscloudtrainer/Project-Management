variable "identifier" {
  description = "Base name for proxy resources"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the proxy security group"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the proxy (same as RDS)"
  type        = list(string)
}

variable "db_instance_identifier" {
  description = "RDS instance identifier to proxy to"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN containing DB credentials"
  type        = string
}

variable "debug_logging" {
  description = "Enable debug logging on proxy"
  type        = bool
  default     = false
}

variable "idle_client_timeout" {
  description = "Idle client timeout in seconds"
  type        = number
  default     = 1800
}

variable "iam_auth" {
  description = "IAM auth requirement: DISABLED or REQUIRED"
  type        = string
  default     = "DISABLED"
}

variable "connection_borrow_timeout" {
  description = "Seconds proxy waits for a connection (max 300)"
  type        = number
  default     = 120
}

variable "max_connections_percent" {
  description = "Max % of RDS max_connections the proxy can use"
  type        = number
  default     = 100
}

variable "max_idle_connections_percent" {
  description = "Max % of idle connections the proxy maintains"
  type        = number
  default     = 50
}
