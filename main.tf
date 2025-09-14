terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "veselabs"
}

resource "github_repository" "infrastructure" {
  name       = "infrastructure"
  visibility = "private"
}


provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "veselabs-terraform-state"
}
