variable "region" {
   type        = string
  description = "region"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "instance_name" {
  type        = string
  description = "EC2 instance Name tag"
}

variable "ami" {
  type        = string
  description = "EC2 ami"
}

variable "sg_name" {
  type        = string
  description = "EC2 security group"
}
