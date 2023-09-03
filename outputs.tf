output "full_repositories_name" {
  description = "Map of repositories with their full name"
  value = {
    for repo in github_repository.repo :
    repo.name => repo.full_name
  }
}

output "repositories_url" {
  description = "Map of repositories with their URL"
  value = {
    for repo in github_repository.repo :
    repo.name => repo.html_url
  }
}

output "branch_protections" {
  description = "Map of branches per repo which their respective rules"
  value       = local.branch_protections
}

output "external_entities" {
  description = "Map of external entities with their respective permissions over repos"
  value       = local.external_entities
}