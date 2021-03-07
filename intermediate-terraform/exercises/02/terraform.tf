terraform {
  backend "s3" {}

  required_providers {
    # this version constraint says that we need to use the most recent 3.x version of the provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
