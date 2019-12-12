variable "env" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "service_acronym" {
  type = "string"
}

variable "subnet_ids" {
  type = list(string)
}

variable "password" {
  type = string
}
