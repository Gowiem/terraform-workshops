terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      # In versions 0.13+, you must specify the source of the provider.
      # This will cause an error in 0.12 however, so we leave it commented out.
      # source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
