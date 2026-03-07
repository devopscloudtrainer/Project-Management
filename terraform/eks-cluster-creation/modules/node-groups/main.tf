resource "aws_launch_template" "node_group_custom_ami" {
  for_each = var.ami_id != "" ? var.node_groups : {}

  name_prefix = "${var.cluster_name}-${each.key}-"
  description = "Launch template for ${each.key} node group with custom AMI"
  
  image_id = var.ami_id

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = each.value.disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [var.node_security_group]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                                        = "${var.cluster_name}-${each.key}-node"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    cluster_name        = var.cluster_name
    cluster_endpoint    = var.cluster_endpoint
    cluster_ca_cert     = var.cluster_ca_cert
    custom_userdata     = each.value.custom_userdata
  }))

  lifecycle {
    create_before_destroy = true
  }
}

# Conditional launch template - without custom AMI (uses EKS-optimized)
resource "aws_launch_template" "node_group_eks_ami" {
  for_each = var.ami_id == "" ? var.node_groups : {}

  name_prefix = "${var.cluster_name}-${each.key}-"
  description = "Launch template for ${each.key} node group"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = each.value.disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [var.node_security_group]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                                        = "${var.cluster_name}-${each.key}-node"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    cluster_name        = var.cluster_name
    cluster_endpoint    = var.cluster_endpoint
    cluster_ca_cert     = var.cluster_ca_cert
    custom_userdata     = each.value.custom_userdata
  }))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  launch_template {
    id      = var.ami_id != "" ? aws_launch_template.node_group_custom_ami[each.key].id : aws_launch_template.node_group_eks_ami[each.key].id
    version = "$Latest"
  }

  update_config {
    max_unavailable_percentage = 33
  }

  labels = {
    role = each.key
  }

  tags = {
    Name = "${var.cluster_name}-${each.key}-node-group"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}
