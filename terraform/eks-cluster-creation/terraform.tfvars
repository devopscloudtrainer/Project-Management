aws_region     = "ap-south-1"
cluster_name   = "devops-eks-cluster"
cluster_version = "1.32"

vpc_cidr = "10.2.0.0/16"
availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
ami_id = "ami-0cc5b51af7421f0a4"

node_groups = {
  general = {
    instance_types = ["t3.medium"]
    desired_size   = 2
    min_size       = 1
    max_size       = 5
    disk_size      = 50
    capacity_type  = "ON_DEMAND"
    custom_userdata = <<-EOT
      # Install custom tools
      yum install -y htop
      yum install -y zip wget at git
    EOT
  }
  
}
