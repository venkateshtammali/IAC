provider "aws" {
  region = "${var.region}"
}

#  Create a VPC
# module "vpc" {
#   source = "../modules/vpc"

#   region = "${var.region}"
#   env    = "${var.env}"
# }

# Create Firehose and ES
# module "fh-es" {
#   source = "./../modules/firehose-es"

#   region = "${var.region}"
#   env    = "${var.env}"
# }

# Create EKS control plane
# module "eks_cp" {
#   source = "./../modules/eks/control-plane"

#   env          = "development"
#   cluster_name = "${module.eks_cp.eks_cluster_name}"
#   subnet_ids   = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
# }

# Create EKS Worker plane
# module "eks_ng" {
#   source = "./../modules/eks/node-group"

#   env          = "development"
#   cluster_name = "${module.eks_cp.eks_cluster_name}"
#   subnet_ids   = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
# }

# Create Redis
# module "elasticcache" {
#   source = "./../modules/elasticcache"

#   subnet_ids = ["${module.vpc.ec_private_1_sn_id}", "${module.vpc.ec_private_2_sn_id}", "${module.vpc.ec_private_3_sn_id}"]
#   vpc_id     = "${module.vpc.vpc_id}"
#   region     = "${var.region}"
#   env        = "${var.env}"
# }

#   env = "development"
#   cluster_name = "${module.eks_cp.eks_cluster_name}"
#   subnet_ids = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
# }

# #creating health checks  
module "r53-hc" {
  source = "./../modules/r53-hc"

  env    = "${var.env}"
  domain = "dev.apty.io"
  alarms_email= ["abc@gmail.com"]
}

# Create RDS
# module "rds" {
#   source = "./../modules/rds"

#   subnet_ids      = ["${module.vpc.rds_private_1_sn_id}", "${module.vpc.rds_private_2_sn_id}", "${module.vpc.rds_private_3_sn_id}"]
#   vpc_id          = "${module.vpc.vpc_id}"
#   service_acronym = "app"
#   env             = "${var.env}"
#   password        = "${var.rds_password}"
# }
