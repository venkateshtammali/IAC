variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "default_tags" {
  type = map
}

variable "dedicated_master_enabled" {
  type = bool
}

variable "master_instance_type" {
  type = string
}

variable "master_instance_count" {
  type = number
}

variable "worker_instance_type" {
  type = string
}

variable "worker_instance_count" {
  type = number
}