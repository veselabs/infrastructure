provider "aws" {
  region = "eu-north-1"
}

module "cluster" {
  source = "../../modules/cluster"
}
