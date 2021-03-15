terraform {
  backend "s3" {}

  required_providers {
    # this version constraint says that we need to use the most recent 3.x version of the provider
    aws = {
      # In versions 0.13+, you must specify the source of the provider.
      # This will cause an error in 0.12 however, so we leave it commented out.
      # source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
