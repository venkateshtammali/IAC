variable "region" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = "string"
}

variable "env" {
  description = "Environment for terraform"
  type        = "string"
}

<<<<<<< HEAD
# variable "rds_password" {
#   type        = "string"
# }
=======
variable "rds_password" {
  type = "string"
}
>>>>>>> b696b2a78a34452782341eb594dc2bd511f79ef2
