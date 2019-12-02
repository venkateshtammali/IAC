locals {
  cluster_name = "${var.env}-eks"
}

resource "aws_iam_role" "eks_rl" {
  name = "${var.env}-eks-rl"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_pl" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_rl.name}"
}

resource "aws_iam_role_policy_attachment" "eks_service_pl" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_rl.name}"
}

resource "aws_cloudwatch_log_group" "eks_cp_lg" {
  name = "/aws/eks/${local.cluster_name}/cluster"
}

resource "aws_eks_cluster" "eks" {
  name                      = "${local.cluster_name}"
  version                   = "1.14"
  role_arn                  = "${aws_iam_role.eks_rl.arn}"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = "${var.subnet_ids}"
  }

  depends_on = [
    "aws_cloudwatch_log_group.eks_cp_lg",
    "aws_iam_role_policy_attachment.eks_cluster_pl",
    "aws_iam_role_policy_attachment.eks_service_pl",
  ]
}
