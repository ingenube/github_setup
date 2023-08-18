variable "owner" {
  description = "The account/organization to create the resources in"
  type        = string
  default     = "ingenube2"
}

variable "github_token" {
  description = "The GitHub token used for authentication."
  type        = string
  default     = ""
}

variable "repositories" {
  description = "Map of GitHub repositories with branch protection rules."
  type = map(object({
    description = string
    branch_protection_rules = map(object({
      up_to_date = optional(bool)
      reviewers  = optional(number)
    }))
  }))
  default = {}
}

variable "teams" {
  description = "Map of teams with their members."
  type = map(object({
    description      = string
    members          = map(string)
    repo_permissions = map(string)
  }))
  default = {}
}

variable "external_users" {
  description = "Map of external users with respective permissions."
  type = map(object({
    repo_permissions = map(string)
  }))
  default = {}
}
