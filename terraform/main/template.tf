provider "aws" {
  region = var.region
}

// validations
locals {
  is_valid_region = "${contains(var.allowed_regions, var.region)}" ? null : file("ERROR: var.region should be valid")
  is_3azs_region  = "${length(split(",", lookup(var.region_az_map, var.region, ""))) >= 3}" ? null : file("Error: Every region should have 3 AZs")
  azs             = "${split(",", lookup(var.region_az_map, var.region))}"
  is_valid_env    = "${contains(var.allowed_envs, var.env)}" ? null : file("ERROR: var.env should be valid")
  is_prod_like    = contains(["staging", "production"], var.env)
}

locals {
  default_tags = {
    Environment = "${var.env}"
  }
  rds = {
    multi_az            = "${local.is_prod_like ? true : false}"
    instance_class      = "${local.is_prod_like ? "db.t2.medium" : "db.t2.medium"}"
    monitoring_interval = "${local.is_prod_like ? 0 : 0}"
  }
  es = {
    dedicated_master_enabled = "${local.is_prod_like ? true : false}"
    master_instance_type     = "c4.large"
    master_instance_count    = 3
    worker_instance_type     = "${local.is_prod_like ? "c4.large" : "t2.medium"}"
    worker_instance_count    = "${local.is_prod_like ? 2 : 1}"
  }
  eks_ng = {
    worker_instance_type = "${local.is_prod_like ? "t2.large" : "t2.medium"}"
  }
}

# Create a VPC
module "vpc" {
  source = "../modules/vpc"

  region       = var.region
  env          = var.env
  azs          = local.azs
  default_tags = local.default_tags
}

# creating kubeconfig
data "aws_eks_cluster" "cluster" {
  name = module.eks_cp.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cp.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}


# Create Firehose and ES
module "fh-es" {
  source = "./../modules/firehose-es"

  env                      = "${var.env}"
  region                   = "${var.region}"
  dedicated_master_enabled = "${local.es.dedicated_master_enabled}"
  master_instance_type     = "${local.es.master_instance_type}"
  master_instance_count    = "${local.es.master_instance_count}"
  worker_instance_type     = "${local.es.worker_instance_type}"
  worker_instance_count    = "${local.es.worker_instance_count}"
  default_tags             = "${local.default_tags}"
}

# Create EKS control plane
module "eks_cp" {
  source = "./../modules/eks/control-plane"

  env          = var.env
  cluster_name = "${var.env}-eks"
  subnet_ids   = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
  default_tags = "${local.default_tags}"
}

module "eks_ng" {
  source = "./../modules/eks/node-group"

  env                  = var.env
  cluster_name         = "${module.eks_cp.eks_cluster_name}"
  subnet_ids           = ["${module.vpc.eks_private_1_sn_id}", "${module.vpc.eks_private_2_sn_id}", "${module.vpc.eks_private_3_sn_id}"]
  worker_instance_type = "${local.eks_ng.worker_instance_type}"
  default_tags         = "${local.default_tags}"
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

  subnet_ids   = ["${module.vpc.ec_private_1_sn_id}", "${module.vpc.ec_private_2_sn_id}", "${module.vpc.ec_private_3_sn_id}"]
  vpc_id       = "${module.vpc.vpc_id}"
  region       = "${var.region}"
  env          = "${var.env}"
  default_tags = "${local.default_tags}"
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

  subnet_ids          = ["${module.vpc.rds_private_1_sn_id}", "${module.vpc.rds_private_2_sn_id}", "${module.vpc.rds_private_3_sn_id}"]
  vpc_id              = "${module.vpc.vpc_id}"
  service_acronym     = "app"
  env                 = "${var.env}"
  instance_class      = "${local.rds.instance_class}"
  multi_az            = "${local.rds.multi_az}"
  password            = "${var.rds_password}"
  monitoring_interval = "${local.rds.monitoring_interval}"
  default_tags        = "${local.default_tags}"
}

# Create ECR
module "ecr" {
  source = "./../modules/ecr"

  env          = "${var.env}"
  name         = "dev-ecr"
  default_tags = "${local.default_tags}"
}

# Create ACM
module "acm" {
  source = "./../modules/acm"

  env          = "${var.env}"
  domain       = "dev-acm.com"
  default_tags = "${local.default_tags}"
}

# create k8 deployment files
module "k8_service" {
  source = "./../k8/service"

  nginx_pod_name = "${module.k8_deployment.nginx_pod_name}"
}

module "k8_ingress" {
  source = "./../k8/ingress"

  nginx_service_name = "${module.k8_service.nginx_service_name}"
}

module "k8_deployment" {
  source = "./../k8/deployment"

}
