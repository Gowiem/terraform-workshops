## Terraform Version ##
######################

## Explicit Version Pin
########################

terraform {
  required_version = "0.12.30"
}

## Great Than Version Pin
##########################

terraform {
  required_version = "> 0.13.3"
}

## Greater Than Or Equal To + Less than Version Pin
####################################################

terraform {
  required_version = ">= 0.12.26, < 0.14"
}

## Pessimistic Version Pin
###########################

terraform {
  required_version = "~> 0.14.7"
}

## Provider Versions ##
######################

# NOTE: The `name = { source, version }` syntax for required_providers was added in Terraform v0.13.
# The below example delineates between the two syntaxes.
terraform {

  # 0.13+ required_providers syntax
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.8.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 1.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  # 0.12.26+ required_providers syntax
  required_providers {
    sops       = "~> 0.5"
    postgresql = "1.8.1"
    helm       = ">= 1.2"
    aws        = "~> 3.0"
  }
}
