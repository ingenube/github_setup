output "full_repositories_name" {
  description = "Map of repositories with their full name"
  value = {
    for repo in github_repository.this :
    repo.name => repo.full_name
  }
}

output "repositories_url" {
  description = "Map of repositories with their URL"
  value = {
    for repo in github_repository.this :
    repo.name => repo.html_url
  }
}