output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "eks_cluster_name" {
  value = "${local.eks_cluster_name}"
}

output "eks_public_1_sn_id" {
  value = "${aws_subnet.eks_public_1_sn.id}"
}

output "eks_public_2_sn_id" {
  value = "${aws_subnet.eks_public_2_sn.id}"
}

output "eks_public_3_sn_id" {
  value = "${aws_subnet.eks_public_3_sn.id}"
}

output "eks_private_1_sn_id" {
  value = "${aws_subnet.eks_private_1_sn.id}"
}

output "eks_private_2_sn_id" {
  value = "${aws_subnet.eks_private_2_sn.id}"
}

output "eks_private_3_sn_id" {
  value = "${aws_subnet.eks_private_3_sn.id}"
}

# Redis subnets as outputs
# output "ec_private_1_sn_id" {
#   value = "${aws_subnet.ec_private_1_sn.id}"
# }

# output "ec_private_2_sn_id" {
#   value = "${aws_subnet.ec_private_2_sn.id}"
# }

# output "ec_private_3_sn_id" {
#   value = "${aws_subnet.ec_private_3_sn.id}"
# }

# # RDS Subnets as outputs
# output "rds_private_1_sn_id" {
#   value = "${aws_subnet.rds_private_1_sn.id}"
# }

# output "rds_private_2_sn_id" {
#   value = "${aws_subnet.rds_private_2_sn.id}"
# }

# output "rds_private_3_sn_id" {
#   value = "${aws_subnet.rds_private_3_sn.id}"
# }