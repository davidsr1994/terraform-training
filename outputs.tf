output "repo_url" {
  value = github_repository.course_repo.html_url
}

output "repo_clone_url" {
  description = "HTTPS clone URL"
  value       = github_repository.course_repo.http_clone_url
  sensitive   = true
}

output "managed_labels" {
  value = {
    for name, label in github_issue_label.labels :
    name => label.color
  }
}