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
  name                   = "infrastructure"
  visibility             = "public"
  auto_init              = true
  delete_branch_on_merge = true
  allow_merge_commit     = true
  allow_squash_merge     = false
  allow_rebase_merge     = false
}

resource "github_branch_default" "default" {
  repository = github_repository.infrastructure.name
  branch     = "master"
  rename     = true
}

resource "github_repository_ruleset" "infrastructure" {
  name        = "master"
  repository  = github_repository.infrastructure.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/master"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 0
    actor_type  = "OrganizationAdmin"
    bypass_mode = "pull_request"
  }

  rules {
    merge_queue {
      merge_method = "MERGE"
    }

    pull_request {
      dismiss_stale_reviews_on_push   = true
      require_last_push_approval      = false # true
      required_approving_review_count = 0     # 1
    }

    required_status_checks {
      required_check {
        context = "Check Flake"
      }
      required_check {
        context = "Succeed"
      }
    }
  }
}

resource "github_repository_environment" "infrastructure_organization" {
  environment = "organization"
  repository  = github_repository.infrastructure.name

  reviewers {
    users = [data.github_user.veselyn.id]
  }

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

resource "github_repository_environment" "infrastructure_development" {
  environment = "development"
  repository  = github_repository.infrastructure.name

  reviewers {
    users = [data.github_user.veselyn.id]
  }

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
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
