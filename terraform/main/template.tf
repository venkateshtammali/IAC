provider "aws" {
  region = "${var.region}"
}

# Create a VPC
module "vpc" {
  source = "../modules/vpc"

  region = "${var.region}"
  env    = "${var.env}"
}

# Create Firehose and ES
# module "fh-es" {
#   source = "./../modules/firehose-es"

#   env    = "${var.env}"
#   region = "${var.region}"
# }

module "eks" {
  source = "./../modules/eks"

  env = "development"
  subnet_ids = ["${module.vpc.eks_public_1_sn_id}", "${module.vpc.eks_public_2_sn_id}", "${module.vpc.eks_public_3_sn_id}"]
}
