provider "aws" {
  region = "${var.region}"
}

module "VPC" {
  source = "../vpc"

  region = "${var.region}"
  env    = "${var.env}"
}
