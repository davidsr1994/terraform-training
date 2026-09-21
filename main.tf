resource "github_repository" "course_repo" {
  name       = var.repo_name
  visibility = var.repo_private ? "private" : "public"
  has_issues = true
  has_wiki   = false
}

resource "github_issue" "welcome" {
  count      = var.welcome_message != null ? 1 : 0
  repository = github_repository.course_repo.name
  title      = "Welcome to ${github_repository.course_repo.name}"
  body       = var.welcome_message
}

locals {
  common_labels = ["erro", "melhoria", "questao"]
}

resource "github_issue_label" "labels" {
  for_each   = toset(local.common_labels)
  repository = github_repository.course_repo.name
  name       = each.value
  color      = "ededed"
}