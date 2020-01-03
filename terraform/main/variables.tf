variable "region" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = "string"
  default     = "us-west-2"

}

variable "env" {
  description = "Environment for terraform"
  type        = "string"
  default     = "development"
}

variable "rds_password" {
  type = "string"
}
