output "node_group_ids" {
  value = { for k, v in aws_eks_node_group.main : k => v.id }
}

output "node_group_arns" {
  value = { for k, v in aws_eks_node_group.main : k => v.arn }
}

output "launch_template_ids" {
  value = var.ami_id != "" ? { for k, v in aws_launch_template.node_group_custom_ami : k => v.id } : { for k, v in aws_launch_template.node_group_eks_ami : k => v.id }
}
