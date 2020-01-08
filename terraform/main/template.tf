provider "aws" {
  region = "${var.region}"
}

locals {
  is_prod_like = contains(["staging", "production"], var.env)
}

locals {
  default_tags = {
    Environment = "${var.env}"
  }
  rds = {
    multi_az = "${ local.is_prod_like ? true : false}" 
  }
  es = {
   dedicated_master_enabled = "${local.is_prod_like ? true : false}" 
   master_instance_type = "c4.large"
   master_instance_count = 3
   worker_instance_type = "${local.is_prod_like ? "c4.large" : "t2.medium"}"
   worker_instance_count = 2
  }
  ng = {
   worker_instance_type = "${local.is_prod_like ? "t2.large" : "t2.medium"}"
   worker_instance_count = 2
  }
}


#  Create a VPC
# module "vpc" {
#   source = "../modules/vpc"

#   region       = "${var.region}"
#   env          = "${var.env}"
#   default_tags = "${local.default_tags}"
# }

# Create Firehose and ES
module "fh-es" {
  source = "./../modules/firehose-es"

  region       = "${var.region}"
  dedicated_master_enabled = "${local.es.dedicated_master_enabled}"
  master_instance_type = "${local.es.master_instance_type}"
  master_instance_count = "${local.es.master_instance_count}"
  worker_instance_type = "${local.es.worker_instance_type}"
  worker_instance_count = "${local.es.worker_instance_count}"
  env          = "${var.env}"
  default_tags = "${local.default_tags}"
}

# Create EKS control plane
# module "eks_cp" {
#   source = "./../modules/eks/control-plane"

#   env          = "development"
#   cluster_name = "${var.env}-eks"
#   subnet_ids   = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
#   default_tags = "${local.default_tags}"
# }

# module "eks_ng" {
#   source = "./../modules/eks/node-group"

#   env          = "development"
#   cluster_name = "${module.eks_cp.eks_cluster_name}"
#   subnet_ids   = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
#   worker_instance_type = "${local.ng.worker_instance_type}"
#   worker_instance_count = "${local.ng.worker_instance_count}"
#   default_tags = "${local.default_tags}"
# }

# module "alb-ingress-controller" {
#   source              = "iplabs/alb-ingress-controller/kubernetes"
#   version             = "2.0.0"
#   aws_iam_path_prefix = "/test/"
#   aws_region_name     = "us-west-2"
#   k8s_cluster_name    = "${module.eks_cp.eks_cluster_name}"
#   aws_vpc_id          = "${module.vpc.vpc_id}"
# }

# Create Redis
# module "elasticcache" {
#   source = "./../modules/elasticcache"

#   subnet_ids = ["${module.vpc.ec_private_1_sn_id}", "${module.vpc.ec_private_2_sn_id}", "${module.vpc.ec_private_3_sn_id}"]
#   vpc_id     = "${module.vpc.vpc_id}"
#   region     = "${var.region}"
#   env        = "${var.env}"
# }

# creating health checks  
# module "r53-hc" {
#   source = "./../modules/r53-hc"

#   env          = "${var.env}"
#   domain       = "dev.apty.io"
#   alarms_email = ["abc@gmail.com"]
#   default_tags = "${local.default_tags}"
# }

# Create RDS
# module "rds" {
#   source = "./../modules/rds"

#   subnet_ids      = ["${module.vpc.rds_private_1_sn_id}", "${module.vpc.rds_private_2_sn_id}", "${module.vpc.rds_private_3_sn_id}"]
#   vpc_id          = "${module.vpc.vpc_id}"
#   service_acronym = "app"
#   env             = "${var.env}"
#   multi_az        = "${local.rds.multi_az}"
#   password        = "${var.rds_password}"
#   default_tags    = "${local.default_tags}"
# }

# Create ECR
# module "ecr" {
#   source = "./../modules/ecr"

#   env          = "${var.env}"
#   name         = "dev-ecr"
#   default_tags = "${local.default_tags}"
# }

# Create ACM
# module "acm" {
#   source = "./../modules/acm"

#   env          = "${var.env}"
#   domain       = "dev-acm.com"
#   default_tags = "${local.default_tags}"
# }