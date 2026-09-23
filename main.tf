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
  for_each   = var.labels
  repository = github_repository.course_repo.name
  name       = each.key
  color      = each.value
}

resource "github_issue_label" "release" {
  count      = var.enable_release_label ? 1 : 0
  repository = github_repository.course_repo.name
  name       = "release"
  color      = "0e8a16"
}

locals {
  label_names_upper = [for name in keys(var.labels) : upper(name)]
}