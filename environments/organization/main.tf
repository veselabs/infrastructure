provider "github" {
  owner = "veselabs"
  app_auth {}
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
    infrastructure = {}
    issues         = { has_issues = true }
    issues-private = { has_issues = true, visibility = "private" }
  }

  name           = each.key
  visibility     = try(each.value.visibility, "public")
  default_branch = local.default_branch
  has_issues     = try(each.value.has_issues, false)
  environments   = try(each.value.environments, [])
}
