data "aws_ssm_parameter" "gh_token" {
  name            = var.token
  with_decryption = true
}

resource "github_repository" "repo" {
  for_each               = local.repos
  name                   = each.value
  visibility             = "public"
  delete_branch_on_merge = true
}

resource "github_team" "team" {
  for_each = var.equipos
  name     = each.key
  privacy  = "closed"
}

resource "github_team_membership" "membership" {
  for_each = local.team_members
  team_id  = each.value.team_id
  username = each.value.member
  role     = "member"
}

resource "github_repository_collaborators" "repo_collaborators" {
  for_each = local.team_repos

  repository = each.value.repo

  team {
    permission = "push"
    team_id    = each.value.team_id
  }

  # External users and teams
  dynamic "user" {
    for_each = [for entity in local.external_entities : entity if entity.type == "user" && each.value.repo == entity.repo]
    content {
      username   = user.value.entity_name
      permission = user.value.permission
    }
  }

  dynamic "team" {
    for_each = [for entity in local.external_entities : entity if entity.type == "team" && each.value.repo == entity.repo]
    content {
      team_id    = github_team.team[team.value.entity_name].id
      permission = team.value.permission
    }
  }
}

resource "github_branch_protection" "branch_protection" {
  for_each = local.branch_protections

  repository_id = each.value.node_id
  pattern       = each.value.pattern

  required_status_checks {
    strict   = each.value.up_to_date == "null" ? false : tobool(each.value.up_to_date)
    contexts = null # TBD
  }
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = each.value.reviewers
  }
}


resource "github_repository_file" "license" {
  for_each = github_repository.repo

  repository          = each.value.name
  file                = "LICENSE"
  overwrite_on_create = true
  commit_message      = "Created while provisioning with Terraform"

  content = file("${path.module}/templates/LICENSE")
}

resource "github_repository_file" "readme" {
  for_each = github_repository.repo

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
  for_each = github_repository.repo

  repository     = each.value.name
  file           = ".github/workflows/cicd.yml"
  commit_message = "Created while provisioning with Terraform"
  content        = file("${path.module}/templates/cicd.yml")

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

locals {
  team_repos = merge([
    for team_name, team_info in var.equipos : {
      for repo in team_info.repositories :
      "${team_name}-${repo}" => {
        team_id = github_team.team[team_name].id
        repo    = repo
      }
    }
  ]...)
  team_members = merge([
    for team_name, team_info in var.equipos : {
      for member in(team_info.members != null ? team_info.members : []) :
      "${team_name}-${member}" => {
        team_id = github_team.team[team_name].id
        member  = member
      }
    }
  ]...)
  repos = toset(flatten([
    for team_name, team_info in var.equipos :
    [for repo in team_info.repositories : repo]
  ]))
  repo_branch = merge(flatten([
    for team_name, team_info in var.equipos : [
      for repo in team_info.repositories : {
        for branch in keys(team_info.protections != null ? team_info.protections : tomap({ "main" = { "reviewers" = 1, "up_to_date" = false } })) :
        "${repo}-${branch}" => {
          node_id = github_repository.repo[repo].node_id,
          pattern = branch
          team    = team_name
        }
      }
    ]
    ]
  )...)
  protections = merge([
    for team_name, team_info in var.equipos : {
      for branch, protection in(team_info.protections != null ? team_info.protections : tomap({ "main" = { "reviewers" = 1, "up_to_date" = false } })) :
      "${team_name}-${branch}" => protection
    }
  ]...)
  branch_protections = {
    for key, value in local.repo_branch :
    key => contains(keys(local.protections), "${value.team}-${value.pattern}") ?
    merge(value, local.protections["${value.team}-${value.pattern}"]) :
    value
  }
  external_entities = merge(flatten([
    for team_name, team_info in var.equipos : [
      for repository in team_info.repositories : {
        for entity, permission in(team_info.external_users != null ? team_info.external_users : {}) :
        "${team_name}-${repository}-${entity}" => {
          team_name   = team_name,
          repo        = repository,
          entity_name = entity,
          permission  = local.permission_type[permission],
          type        = strcontains(entity, "team") ? "team" : "user"
        }
      }
    ]
    ]
  )...)
  permission_type = {
    read  = "pull"
    write = "push"
  }
}
