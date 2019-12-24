provider "aws" {
  region = "${var.region}"
}

locals {
  default_tags = {
    Environment = "development"
  }
}

#  Create a VPC
module "vpc" {
  source = "../modules/vpc"

  region       = "${var.region}"
  env          = "${var.env}"
  default_tags = "${local.default_tags}"
}

# Create Firehose and ES
module "fh-es" {
  source = "./../modules/firehose-es"

  region       = "${var.region}"
  env          = "${var.env}"
  default_tags = "${local.default_tags}"
}

# Create EKS control plane
module "eks_cp" {
  source = "./../modules/eks/control-plane"

  env          = "development"
  cluster_name = "${var.env}-eks"
  subnet_ids   = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
  default_tags = "${local.default_tags}"
}

module "eks_ng" {
  source = "./../modules/eks/node-group"

  env          = "development"
  cluster_name = "${module.eks_cp.eks_cluster_name}"
  subnet_ids   = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
  default_tags = "${local.default_tags}"
}

module "alb-ingress-controller" {
  source              = "iplabs/alb-ingress-controller/kubernetes"
  version             = "2.0.0"
  aws_iam_path_prefix = "/test/"
  aws_region_name     = "us-west-2"
  k8s_cluster_name    = "${module.eks_cp.eks_cluster_name}"
  aws_vpc_id          = "${module.vpc.vpc_id}"
}

# Create Redis
module "elasticcache" {
  source = "./../modules/elasticcache"

  subnet_ids = ["${module.vpc.ec_private_1_sn_id}", "${module.vpc.ec_private_2_sn_id}", "${module.vpc.ec_private_3_sn_id}"]
  vpc_id     = "${module.vpc.vpc_id}"
  region     = "${var.region}"
  env        = "${var.env}"
}

# creating health checks  
module "r53-hc" {
  source = "./../modules/r53-hc"

  env          = "${var.env}"
  domain       = "dev.apty.io"
  alarms_email = ["abc@gmail.com"]
  default_tags = "${local.default_tags}"
}

# Create RDS
module "rds" {
  source = "./../modules/rds"

  subnet_ids      = ["${module.vpc.rds_private_1_sn_id}", "${module.vpc.rds_private_2_sn_id}", "${module.vpc.rds_private_3_sn_id}"]
  vpc_id          = "${module.vpc.vpc_id}"
  service_acronym = "app"
  env             = "${var.env}"
  password        = "${var.rds_password}"
  default_tags    = "${local.default_tags}"
}

# Create ECR
module "ecr" {
  source = "./../modules/ecr"

  env    = "${var.env}"
  default_tags    = "${local.default_tags}"
}
