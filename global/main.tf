resource "github_repository" "infrastructure" {
  name       = "infrastructure"
  visibility = "private"
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
