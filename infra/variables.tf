variable "prefix" {
  description = "Your assigned prefix (keeps names unique in the shared subscription)."
  type        = string
}

variable "location" {
  type    = string
  default = "spaincentral"
}

variable "db_password" {
  type      = string
  sensitive = true
}

locals {
  common_tags = {
    environment = "prod"
  }
}
