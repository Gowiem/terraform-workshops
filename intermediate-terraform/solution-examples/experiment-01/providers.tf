provider "aws" {

  region = local.env[terraform.workspace].region
}

provider "template" {
  version = "~> 2.1"
}
