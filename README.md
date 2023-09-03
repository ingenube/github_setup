# github_setup
This Terraform module manages GitHub resources including repositories, teams, permissions, branch protection rules and a common GitHub Action for each repository.

## Features
- Create a given number of repositories with specific names.
- Set up teams with specific names and members.
- Assign permissions to teams for repositories.
- Assing permissions to external users for repositories.
- Configure branch protection rules for repositories.
- Initialize each repository with a README, LICENSE and GitHub Action.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.14.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 5.34.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_branch_protection.branch_protection](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.repo](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_collaborators.repo_collaborators](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborators) | resource |
| [github_repository_file.github_action](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.license](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.readme](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_team.team](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_membership.membership](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |
| [aws_ssm_parameter.gh_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_equipos"></a> [equipos](#input\_equipos) | n/a | <pre>map(object({<br>    members      = optional(list(string))<br>    repositories = list(string)<br>    protections = optional(map(object({<br>      reviewers  = optional(number)<br>      up_to_date = optional(bool)<br>    })))<br>    external_users = optional(map(string))<br>  }))</pre> | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The account/organization to create the resources in | `string` | n/a | yes |
| <a name="input_token"></a> [token](#input\_token) | The name of your SSM parameter where you store the GitHub token | `string` | `"gh-token"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_branch_protections"></a> [branch\_protections](#output\_branch\_protections) | Map of branches per repo which their respective rules |
| <a name="output_external_entities"></a> [external\_entities](#output\_external\_entities) | Map of external entities with their respective permissions over repos |
| <a name="output_full_repositories_name"></a> [full\_repositories\_name](#output\_full\_repositories\_name) | Map of repositories with their full name |
| <a name="output_repositories_url"></a> [repositories\_url](#output\_repositories\_url) | Map of repositories with their URL |
<!-- END_TF_DOCS -->