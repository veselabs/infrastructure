provider "github" {
  owner = "veselabs"
  app_auth {}
}

provider "aws" {
  region = "eu-north-1"
}

locals {
  default_branch = "master"
}

resource "github_membership" "veselyn" {
  username = "veselyn"
  role     = "admin"
}

module "github_repositories" {
  source = "../../modules/github-repository"

  for_each = {
    infrastructure = { environments = ["bootstrap", "organization"] }
    issues         = { has_issues = true }
    issues-private = { has_issues = true, visibility = "private" }
  }

  name           = each.key
  visibility     = try(each.value.visibility, "public")
  default_branch = local.default_branch
  has_issues     = try(each.value.has_issues, false)
  environments   = try(each.value.environments, [])
}

module "iam_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"
  version = "~> 6.2.1"

  url = "https://token.actions.githubusercontent.com"
}

module "iam_role_github_oidc_read" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.2.1"

  enable_github_oidc = true

  name            = "gha-infrastructure-read"
  use_name_prefix = false

  oidc_wildcard_subjects = ["veselabs/infrastructure:*"]

  policies = {
    ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }

  create_inline_policy = true
  inline_policy_permissions = {
    AllowS3BucketAccess = {
      effect    = "Allow"
      actions   = ["s3:PutObject", "s3:DeleteObject"]
      resources = ["arn:aws:s3:::veselabs-terraform-state/*/terraform.tfstate.tflock"]
    }
    DenyPlanUpgrade = {
      effect    = "Deny"
      actions   = ["freetier:UpgradeAccountPlan"]
      resources = ["*"]
    }
  }
}

module "iam_role_github_oidc_write" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.2.1"

  enable_github_oidc = true

  name            = "gha-infrastructure-write"
  use_name_prefix = false

  oidc_wildcard_subjects = [
    "veselabs/infrastructure:environment:bootstrap",
    "veselabs/infrastructure:environment:organization",
  ]

  policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  create_inline_policy = true
  inline_policy_permissions = {
    DenyPlanUpgrade = {
      effect    = "Deny"
      actions   = ["freetier:UpgradeAccountPlan"]
      resources = ["*"]
    }
  }
}
