resource "github_repository" "infrastructure" {
  name       = "infrastructure"
  visibility = "private"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "veselabs-terraform-state"
}
