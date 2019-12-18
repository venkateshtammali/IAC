resource "aws_iam_role" "ng_rl" {
  name = "${var.env}-ng-rl"
  tags = "${merge(var.default_tags, map("Name", "${var.env}-ng-rl", ))}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "ng_worker_pl" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ng_rl.name
}

resource "aws_iam_role_policy_attachment" "ng_cni_pl" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ng_rl.name
}

resource "aws_iam_role_policy_attachment" "ng_ecr_pl" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ng_rl.name
}

resource "aws_iam_role_policy_attachment" "ng_tags_pl" {
  policy_arn = "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorReadOnlyAccess"
  role       = aws_iam_role.ng_rl.name
}

# TODO: Create ALBIngress policy using terraform
# https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
resource "aws_iam_role_policy_attachment" "ng_ingress_pl" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.ng_rl.name
}

resource "aws_eks_node_group" "ng" {
  version         = "1.14"
  cluster_name    = "${var.cluster_name}"
  tags            = "${merge(var.default_tags, map("Name", "${var.cluster_name}", ))}"
  node_group_name = "${var.env}-ng"
  node_role_arn   = "${aws_iam_role.ng_rl.arn}"
  subnet_ids      = "${var.subnet_ids}"
  instance_types  = ["t2.large"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.ng_worker_pl,
    aws_iam_role_policy_attachment.ng_cni_pl,
    aws_iam_role_policy_attachment.ng_ecr_pl,
  ]
}