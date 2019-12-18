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
  tags                 = "${merge(var.default_tags, map("Name", "${var.env}-vpc", ))}"

  # Install kubectl depending on os
  provisioner "local-exec" {
    command = "echo Add provisioner to install kubectl, aws-iam authenticator and update kube-config"
  }
}

# Subnets
resource "aws_subnet" "eks_public_1_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2a"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "${var.env}-eks-public-1-sn",
      "kubernetes.io/cluster/${local.eks_cluster_name}", "shared",
      "kubernetes.io/role/internal-elb", 1
    )
  )}"
}
resource "aws_subnet" "eks_public_2_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2b"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "${var.env}-eks-public-2-sn",
      "kubernetes.io/cluster/${local.eks_cluster_name}", "shared",
      "kubernetes.io/role/internal-elb", 1
    )
  )}"
}
resource "aws_subnet" "eks_public_3_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2c"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "${var.env}-eks-public-3-sn",
      "kubernetes.io/cluster/${local.eks_cluster_name}", "shared",
      "kubernetes.io/role/internal-elb", 1
    )
  )}"

}
resource "aws_subnet" "eks_private_1_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2a"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "${var.env}-eks-private-1-sn",
      "kubernetes.io/cluster/${local.eks_cluster_name}", "shared",
      "kubernetes.io/role/internal-elb", 1
    )
  )}"
}
resource "aws_subnet" "eks_private_2_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2b"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "${var.env}-eks-private-2-sn",
      "kubernetes.io/cluster/${local.eks_cluster_name}", "shared",
      "kubernetes.io/role/internal-elb", 1
    )
  )}"

}
resource "aws_subnet" "eks_private_3_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2c"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "${var.env}-eks-private-3-sn",
      "kubernetes.io/cluster/${local.eks_cluster_name}", "shared",
      "kubernetes.io/role/internal-elb", 1
    )
  )}"

}
# NACL for EKS public subnets
resource "aws_network_acl" "eks_public_nacl" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = [
    "${aws_subnet.eks_public_1_sn.id}",
    "${aws_subnet.eks_public_2_sn.id}",
    "${aws_subnet.eks_public_3_sn.id}"
  ]

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = "${merge(var.default_tags, map("Name", "${var.env}-eks-public-nacl", ))}"

}
# NACL for EKS private subnets
resource "aws_network_acl" "eks_private_nacl" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = [
    "${aws_subnet.eks_private_1_sn.id}",
    "${aws_subnet.eks_private_2_sn.id}",
    "${aws_subnet.eks_private_3_sn.id}"
  ]

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = "${merge(var.default_tags, map("Name", "${var.env}-eks-private-nacl", ))}"
}

#  Internet GW
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.default_tags, map("Name", "${var.env}-igw", ))}"

}
#  route tables
resource "aws_route_table" "eks_public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = "${merge(var.default_tags, map("Name", "${var.env}-eks-public-rt", ))}"

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

#  nat gw
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.eks_public_1_sn.id}"
  depends_on    = ["aws_internet_gateway.igw"]

  tags = "${merge(var.default_tags, map("Name", "${var.env}-nat", ))}"

}
resource "aws_route_table" "eks_private_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags = "${merge(var.default_tags, map("Name", "${var.env}-eks-private-rt", ))}"

}
# Associating route table with private subnets
resource "aws_route_table_association" "eks_private_1_rt_assoc" {
  subnet_id      = "${aws_subnet.eks_private_1_sn.id}"
  route_table_id = "${aws_route_table.eks_private_rt.id}"
}

resource "aws_route_table_association" "eks_private_2_rt_assoc" {
  subnet_id      = "${aws_subnet.eks_private_2_sn.id}"
  route_table_id = "${aws_route_table.eks_private_rt.id}"
}

resource "aws_route_table_association" "eks_private_3_rt_assoc" {
  subnet_id      = "${aws_subnet.eks_private_3_sn.id}"
  route_table_id = "${aws_route_table.eks_private_rt.id}"
}

#  Redis subnets
resource "aws_subnet" "ec_private_1_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.7.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2a"

  tags = "${merge(var.default_tags, map("Name", "${var.env}-ec-private-sn-1", ))}"

}
resource "aws_subnet" "ec_private_2_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2b"

  tags = "${merge(var.default_tags, map("Name", "${var.env}-ec-private-sn-2", ))}"
}
resource "aws_subnet" "ec_private_3_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.9.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2c"

  tags = "${merge(var.default_tags, map("Name", "${var.env}-ec-private-sn-3", ))}"
}
# Redis NACL
resource "aws_network_acl" "ec_private_nacl" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = [
    "${aws_subnet.ec_private_1_sn.id}",
    "${aws_subnet.ec_private_2_sn.id}",
    "${aws_subnet.ec_private_3_sn.id}"
  ]

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = "${merge(var.default_tags, map("Name", "${var.env}-ec-private-nacl", ))}"
}
# Redis Route table
resource "aws_route_table" "ec_private_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags = "${merge(var.default_tags, map("Name", "${var.env}-ec-private-rt", ))}"
}
#  NACL for RDS
resource "aws_network_acl" "rds_private_nacl" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = [
    "${aws_subnet.rds_private_1_sn.id}",
    "${aws_subnet.rds_private_2_sn.id}",
    "${aws_subnet.rds_private_3_sn.id}"
  ]

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = "${merge(var.default_tags, map("Name", "${var.env}-rds-private-rt", ))}"
}
#  Associating Redis route table with private subnets
resource "aws_route_table_association" "ec_private_1_rt_assoc" {
  subnet_id      = "${aws_subnet.ec_private_1_sn.id}"
  route_table_id = "${aws_route_table.ec_private_rt.id}"
}

resource "aws_route_table_association" "ec_private_2_rt_assoc" {
  subnet_id      = "${aws_subnet.ec_private_2_sn.id}"
  route_table_id = "${aws_route_table.ec_private_rt.id}"
}

resource "aws_route_table_association" "ec_private_3_rt_assoc" {
  subnet_id      = "${aws_subnet.ec_private_3_sn.id}"
  route_table_id = "${aws_route_table.ec_private_rt.id}"
}


#  RDS subnets
resource "aws_subnet" "rds_private_1_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2a"

  tags = "${merge(var.default_tags, map("Name", "${var.env}-rds-private-sn-1", ))}"
}
resource "aws_subnet" "rds_private_2_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2b"

  tags = "${merge(var.default_tags, map("Name", "${var.env}-rds-private-sn-2", ))}"
}

resource "aws_subnet" "rds_private_3_sn" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.12.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-2c"

  tags = "${merge(var.default_tags, map("Name", "${var.env}-rds-private-sn-3", ))}"
}

#  RDS Route table
resource "aws_route_table" "rds_private_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }


  tags = "${merge(var.default_tags, map("Name", "${var.env}-rds-private-rt", ))}"
}

#  Associating rds route tables with private subnets
resource "aws_route_table_association" "rds_private_1_rt_assoc" {
  subnet_id      = "${aws_subnet.rds_private_1_sn.id}"
  route_table_id = "${aws_route_table.rds_private_rt.id}"
}

resource "aws_route_table_association" "rds_private_2_rt_assoc" {
  subnet_id      = "${aws_subnet.rds_private_2_sn.id}"
  route_table_id = "${aws_route_table.rds_private_rt.id}"
}

resource "aws_route_table_association" "rds_private_3_rt_assoc" {
  subnet_id      = "${aws_subnet.rds_private_3_sn.id}"
  route_table_id = "${aws_route_table.rds_private_rt.id}"
}
