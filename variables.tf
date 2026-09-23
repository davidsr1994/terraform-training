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

variable "labels" {
  type        = map(string) # name => hex color
  description = "Issue labels to manage on the repo."
}

variable "enable_release_label" {
  type    = bool
  default = false
}
