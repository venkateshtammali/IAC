variable "region" {
  type = "string"
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

variable "at_rest_encryption_enabled" {
  type        = bool
  default     = true
  description = "Enable encryption at rest"
}