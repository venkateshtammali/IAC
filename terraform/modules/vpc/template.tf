locals {
  eks_cluster_name = "${var.env}-eks"
}


# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "${var.env}-vpc"
  }
}

# Subnets
resource "aws_subnet" "eks_public_1_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "${var.env}-eks-public-1-sn"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "eks_public_2_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2b"

  tags = {
    Name = "${var.env}-eks-public-2-sn"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}
resource "aws_subnet" "eks_public_3_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2c"

  tags = {
    Name = "${var.env}-eks-public-3-sn"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}
resource "aws_subnet" "eks_private_1_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "${var.env}-eks-private-1-sn"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}
resource "aws_subnet" "eks_private_2_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2b"

  tags = {
    Name = "${var.env}-eks-private-2-sn"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}
resource "aws_subnet" "eks_private_3_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2c"

  tags = {
    Name = "${var.env}-eks-private-3-sn"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Internet GW
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${var.env}-igw"
  }
}

# route tables
resource "aws_route_table" "eks_public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "${var.env}-eks-public-rt"
  }
}

# route associations public
resource "aws_route_table_association" "eks_public_1_rt_assoc" {
  subnet_id      = "${aws_subnet.eks_public_1_sn.id}"
  route_table_id = "${aws_route_table.eks_public_rt.id}"
}
resource "aws_route_table_association" "eks_public_2_rt_assoc" {
  subnet_id      = "${aws_subnet.eks_public_2_sn.id}"
  route_table_id = "${aws_route_table.eks_public_rt.id}"
}
resource "aws_route_table_association" "eks_public_3_rt_assoc" {
  subnet_id      = "${aws_subnet.eks_public_3_sn.id}"
  route_table_id = "${aws_route_table.eks_public_rt.id}"
}

# nat gw
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.eks_public_1_sn.id}"
  depends_on    = ["aws_internet_gateway.igw"]

  tags = {
    Name = "${var.env}-nat"
  }
}

resource "aws_route_table" "eks_private_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags = {
    Name = "${var.env}-eks-private-rt"
  }
}

# Associating route table with private subnets
resource "aws_route_table_association" "private-1-rt-association" {
  subnet_id      = "${aws_subnet.eks_private_1_sn.id}"
  route_table_id = "${aws_route_table.eks_private_rt.id}"
}

resource "aws_route_table_association" "private-2-rt-association" {
  subnet_id      = "${aws_subnet.eks_private_2_sn.id}"
  route_table_id = "${aws_route_table.eks_private_rt.id}"
}

resource "aws_route_table_association" "private-3-rt-association" {
  subnet_id      = "${aws_subnet.eks_private_3_sn.id}"
  route_table_id = "${aws_route_table.eks_private_rt.id}"
}

