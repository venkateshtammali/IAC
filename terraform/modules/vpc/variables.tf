variable "region" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = "string"
  default     = "us-east-1"
}

variable "env" {
  description = "Environment for terraform"
  type = "string"
}