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

locals {
  default_branch = "master"
}

module "github_repositories" {
  source = "../../modules/github/repository"

  for_each = {
    infrastructure = {
      environments = ["organization", "development"]
    }
  }

  name           = each.key
  default_branch = local.default_branch
  environments   = each.value.environments
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

  oidc_wildcard_subjects = ["veselabs/infrastructure:*"]

  policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  create_inline_policy = true
  inline_policy_permissions = {
    DenyPlanUpgrade = {
      effect    = "Deny",
      actions   = ["freetier:UpgradeAccountPlan"]
      resources = ["*"]
    }
  }
}
