# github_setup
This Terraform module manages GitHub resources including repositories, teams, permissions, branch protection rules and a common GitHub Action for each repository.

## Features
- Create a given number of repositories with specific names.
- Set up teams with specific names and members.
- Assign permissions to teams for repositories.
- Assing permissions to external users for repositories.
- Configure branch protection rules for repositories.
- Initialize each repository with a GitHub Action.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.13.1 |
| <a name="provider_github"></a> [github](#provider\_github) | 5.33.0 |

## Resources

| Name | Type |
|------|------|
| [github_branch_protection.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_collaborator.external](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborator) | resource |
| [github_repository_file.github_action](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.license](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.readme](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_team.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_membership.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |
| [github_team_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [aws_ssm_parameter.gh_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_external_users"></a> [external\_users](#input\_external\_users) | Map of external users with respective permissions. | <pre>map(object({<br>    repo_permissions = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | The account/organization to create the resources in | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | Map of GitHub repositories with branch protection rules. | <pre>map(object({<br>    description = string<br>    branch_protection_rules = map(object({<br>      up_to_date = optional(bool)<br>      reviewers  = optional(number)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_teams"></a> [teams](#input\_teams) | Map of teams with their members. | <pre>map(object({<br>    description      = string<br>    members          = map(string)<br>    repo_permissions = map(string)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_full_repositories_name"></a> [full\_repositories\_name](#output\_full\_repositories\_name) | Map of repositories with their full name |
| <a name="output_repositories_url"></a> [repositories\_url](#output\_repositories\_url) | Map of repositories with their URL |
<!-- END_TF_DOCS -->