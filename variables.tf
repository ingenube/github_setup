variable "owner" {
  description = "The account/organization to create the resources in"
  type        = string
}

variable "token" {
  description = "The name of your SSM parameter where you store the GitHub token"
  default     = "gh-token"
}

variable "equipos" {
  type = map(object({
    members      = optional(list(string))
    repositories = list(string)
    protections = optional(map(object({
      reviewers  = optional(number)
      up_to_date = optional(bool)
    })))
    external_users = optional(map(string))
  }))
}