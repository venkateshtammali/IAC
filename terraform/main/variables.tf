variable "region" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = string
}

variable "env" {
  description = "Environment for terraform"
  type        = string
}

variable "rds_password" {
  type = string
}

variable "allowed_envs" {
  description = "Environment ID"
  type        = "list"
  default     = ["development", "qa", "staging", "production"]
}

variable "allowed_regions" {
  type = list
  default = [
    "us-east-1", "us-east-2", "us-west-1", "us-west-2", "ap-east-1", "ap-south-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2",
    "ap-northeast-1", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3", "eu-north-1", "me-south-1",
    "sa-east-1"
  ]
}

variable "region_az_map" {
  type = map
  default = {
    us-east-1      = "us-east-1a,us-east-1b,us-east-1c"
    us-east-2      = "us-east-2a,us-east-2b,us-east-2c"
    us-west-2      = "us-west-2a,us-west-2b,us-west-2c"
    ap-south-1     = "ap-south-1a,ap-south-1b,ap-south-1c"
    ap-northeast-2 = "ap-northeast-2a,ap-northeast-2b,ap-northeast-2c"
    ap-southeast-1 = "ap-southeast-1a,ap-southeast-1b,ap-southeast-1c"
    ap-southeast-2 = "ap-southeast-2a,ap-southeast-2b,ap-southeast-2c"
    ap-northeast-1 = "ap-northeast-1a,ap-northeast-1b,ap-northeast-1c"
    eu-central-1   = "eu-central-1a,eu-central-1b,eu-central-1c"
    eu-west-1      = "eu-west-1a,eu-west-1b,eu-west-1a"
    eu-west-2      = "eu-west-2a,eu-west-2b,eu-west-2c"
    eu-west-3      = "eu-west-3a,eu-west-3b,eu-west-3c"
    eu-north-1     = "eu-north-1a,eu-north-1b,eu-north-1c"
    sa-east-1      = "sa-east-1a,sa-east-1b,sa-east-1c"
  }
}