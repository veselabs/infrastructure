data "github_user" "veselyn" {
  username = "veselyn"
}

resource "github_repository" "this" {
  name       = var.name
  visibility = "public"
  auto_init  = true

  delete_branch_on_merge = true

  allow_merge_commit = true
  allow_squash_merge = false
  allow_rebase_merge = false

  has_issues = var.has_issues
}

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = var.default_branch
  rename     = true
}

resource "github_repository_ruleset" "this" {
  depends_on = [github_branch_default.this]

  name        = var.default_branch
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/${var.default_branch}"]
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

resource "github_repository_environment" "this" {
  for_each = var.environments

  environment = each.value
  repository  = github_repository.this.name

  reviewers {
    users = [data.github_user.veselyn.id]
  }

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}
