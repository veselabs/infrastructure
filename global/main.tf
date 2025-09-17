provider "github" {
  owner = "veselabs"
  app_auth {}
}

provider "aws" {
  region = "eu-north-1"
}

resource "github_membership" "veselyn" {
  username = "veselyn"
  role     = "admin"
}

data "github_user" "veselyn" {
  username = "veselyn"
}

resource "github_repository" "infrastructure" {
  name       = "infrastructure"
  visibility = "public"
  auto_init  = true
}

resource "github_repository_environment" "infrastructure_global" {
  environment = "global"
  repository  = github_repository.infrastructure.name

  reviewers {
    users = [data.github_user.veselyn.id]
  }

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "infrastructure_global" {
  repository     = github_repository.infrastructure.name
  environment    = github_repository_environment.infrastructure_global.environment
  branch_pattern = "master"
}

module "s3_bucket_terraform_state" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.7.0"

  bucket = "veselabs-terraform-state"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

module "iam_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"
  version = "~> 6.2.1"

  url = "https://token.actions.githubusercontent.com"
}

module "iam_role_github_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.2.1"

  enable_github_oidc = true

  name            = "gha-infrastructure"
  use_name_prefix = false

  oidc_wildcard_subjects = [
    "veselabs/infrastructure:ref:refs/heads/master",
    "veselabs/infrastructure:environment:global",
  ]

  policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
}
