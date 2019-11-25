provider "aws" {
  region = "${var.region}"
}

# module "VPC" {
#   source = "../vpc"

#   region = "${var.region}"
#   env    = "${var.env}"
# }

module "fh-es" {
  source = "./../firehose-es"

  env    = "${var.env}"
  region = "${var.region}"
}

