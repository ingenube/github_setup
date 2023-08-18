provider "github" {
  token = data.aws_ssm_parameter.gh_token.value
  owner = var.owner
}

provider "aws" {
  region = "us-east-1"
}