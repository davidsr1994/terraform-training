variable "repo_name" {
  description = "The name of the repository"
  type        = string
  default     = "terraform-training"
  validation {
    condition     = length(var.repo_name) <= 20
    error_message = "The repository name must be 20 characters or fewer."
  }
}

variable "repo_private" {
  description = "Whether the repository is private"
  type        = bool
  default     = false
}

variable "welcome_message" {
  description = "Optional welcome message posted as an issue"
  type        = string
  default     = null
}