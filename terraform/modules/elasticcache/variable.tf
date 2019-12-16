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
