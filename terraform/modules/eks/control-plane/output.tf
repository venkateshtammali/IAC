output "eks_cluster_name" {
  value = "${aws_eks_cluster.eks.name}"
}

output "cluster_id" {
  value = "${aws_eks_cluster.eks.id}"
}
