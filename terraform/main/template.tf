provider "aws" {
  region = "${var.region}"
}

#  Create a VPC
 module "vpc" {
   source = "../modules/vpc"

   region = "${var.region}"
   env    = "${var.env}"
 }

# Create Firehose and ES
module "fh-es" {
  source = "./../modules/firehose-es"

  env    = "${var.env}"
  region = "${var.region}"
}

module "eks_cp" {
  source = "./../modules/eks/control-plane"

  env = "development"
  cluster_name = "${module.vpc.eks_cluster_name}"
  subnet_ids = ["${module.vpc.eks_public_1_sn_id}", "${module.vpc.eks_public_2_sn_id}", "${module.vpc.eks_public_3_sn_id}"]
}

module "eks_ng" {
  source = "./../modules/eks/node-group"

  env = "development"
  cluster_name = "${module.eks_cp.eks_cluster_name}"
  subnet_ids = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
}

module "elasticcache" {
  source = "./../modules/elasticcache"  
    
  subnet_ids = ["${module.vpc.ec_private_1_sn_id}", "${module.vpc.ec_private_2_sn_id}", "${module.vpc.ec_private_3_sn_id}"]
  vpc_id = "${module.vpc.vpc_id}"
  region = "${var.region}"
  env    = "${var.env}"
}