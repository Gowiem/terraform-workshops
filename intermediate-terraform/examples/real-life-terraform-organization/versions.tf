terraform {
  required_version = "1.1.3"

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.6"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.0"
    }
  }
}
