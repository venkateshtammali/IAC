variable "region" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = string
}

variable "env" {
  description = "Environment for terraform"
  type        = string
}

variable "default_tags" {
  type = map
}

variable "azs" {
  type = list(string)
}