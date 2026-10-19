variable "prefix" {
	type = string
}

variable "location" {
	type = string
}

variable "db_password" {
	type      = string
	sensitive = true
}

variable "tags" {
	type = map(string)
}
