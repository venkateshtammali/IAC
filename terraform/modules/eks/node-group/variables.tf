variable "env" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "default_tags" {
  type = map
}

variable "worker_instance_type" {
  type = string
}