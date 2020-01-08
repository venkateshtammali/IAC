variable "email_addresses" {
  type        = "list"
  description = "Email address to send notifications to"
}

variable "display_name" {
  type = string
}

variable "default_tags" {
  type = map
}
