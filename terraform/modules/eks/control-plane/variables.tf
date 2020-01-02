variable "env" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "subnet_ids" {
  type = list(string)
}

variable "default_tags" {
  type = "map"
}

variable "region" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = "string"
  default     = "us-west-2"

}
