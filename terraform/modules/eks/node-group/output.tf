output "cluster_name" {
  value       = "${aws_eks_node_group.ng.cluster_name}"
  description = "EKS cluster name"
}