terraform {
  backend "s3" {
    region       = "eu-north-1"
    bucket       = "veselabs-terraform-state"
    key          = "development/terraform.tfstate"
    use_lockfile = true
  }
}
