variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_cert" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_security_group" {
  type = string
}

variable "node_groups" {
  type = map(object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
    disk_size      = number
    capacity_type  = string
    custom_userdata = string
  }))
}



variable "ami_id" {
  description = "AMI ID for worker nodes (leave empty for EKS-optimized AMI)"
  type        = string
  default     = ""
}
