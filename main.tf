data "aws_ssm_parameter" "gh_token" {
  name            = "gh-token"
  with_decryption = true
}

resource "github_repository" "this" {
  for_each               = var.repositories
  name                   = each.key
  description            = each.value.description
  visibility             = "public"
  delete_branch_on_merge = true
}

resource "github_team" "this" {
  for_each    = var.teams
  name        = each.key
  description = each.value.description
  privacy     = "closed"
}

resource "github_team_membership" "this" {
  for_each = local.team_members
  team_id  = each.value.team_id
  username = each.value.username
  role     = each.value.role
}

resource "github_team_repository" "this" {
  for_each = local.team_repos

  team_id    = each.value.team_id
  repository = each.value.repository
  permission = each.value.permission
}

resource "github_repository_collaborator" "external" {
  for_each = local.external_users

  repository = each.value.repository
  username   = each.value.user
  permission = each.value.permission
}

resource "github_branch_protection" "this" {
  for_each = local.branch_rules

  repository_id = each.value.repository
  pattern       = each.value.pattern

  required_status_checks {
    strict   = each.value.up_to_date
    contexts = null # TBD
  }
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = each.value.reviewers
  }
}


resource "github_repository_file" "license" {
  for_each = github_repository.this

  repository          = each.value.name
  file                = "LICENSE"
  overwrite_on_create = true
  commit_message      = "Created while provisioning with Terraform"

  content = file("${path.module}/templates/LICENSE")
}

resource "github_repository_file" "readme" {
  for_each = github_repository.this

  repository     = each.value.name
  file           = "README.md"
  commit_message = "Created while provisioning with Terraform"
  content        = <<EOT
# ${each.value.name}
Welcome to the ${each.value.name} repository
  EOT

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

resource "github_repository_file" "github_action" {
  for_each = github_repository.this

  repository     = each.value.name
  file           = ".github/workflows/cicd.yml"
  commit_message = "Created while provisioning with Terraform"
  content        = file("${path.module}/templates/cicd.yml")
}

locals {
  team_repos = merge([
    for team_name, team_info in var.teams : {
      for repo_name, repo_permission in team_info.repo_permissions :
      "${team_name}-${repo_name}" => {
        team_id    = github_team.this[team_name].id
        repository = repo_name
        permission = repo_permission
      }
    }
  ]...)
  team_members = merge([
    for team_name, team_info in var.teams : {
      for user, role in team_info.members :
      "${team_name}-${user}" => {
        team_id  = github_team.this[team_name].id
        username = user
        role     = role
      }
    }
  ]...)
  external_users = merge([
    for ext_user, info in var.external_users : {
      for repo_name, repo_permission in info.repo_permissions :
      "${ext_user}-${repo_name}" => {
        user       = ext_user
        repository = repo_name
        permission = repo_permission
      }
    }
  ]...)
  branch_rules = merge([
    for repo, info in var.repositories : {
      for branch, rules in info.branch_protection_rules :
      "${repo}-${branch}" => {
        pattern    = branch
        repository = repo
        reviewers  = lookup(rules, "reviewers", 1)
        up_to_date = lookup(rules, "up_to_date", false)
      }
    }
  ]...)

}
