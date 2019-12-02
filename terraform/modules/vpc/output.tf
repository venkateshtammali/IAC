output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
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