variable "region" {
  type    = "string"
  default = "us-east-1"
}

variable "env" {
  description = "Environment for terraform"
  type        = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "subnet_ids" {
  type = list(string)
}
