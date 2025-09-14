terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = var.github_organization
}

resource "github_repository" "infrastructure" {
  name       = "infrastructure"
  visibility = "private"
}
