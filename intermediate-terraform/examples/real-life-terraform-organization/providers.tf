provider "aws" {
  region = var.region
  assume_role {
    # ...
  }
}
