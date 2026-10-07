variable "prefix" {
  description = "Your assigned prefix (keeps names unique in the shared subscription)."
  type        = string
}

variable "location" {
  type    = string
  default = "westeurope"
}