provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source      = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.27.0"

  namespace   = "mp"
  environment = "ue1"
  stage       = "teaching"
  name        = "default"
  cidr_block  = "10.20.0.0/16"

  tags = { Protected = "true" }
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.39.5"

  namespace   = "mp"
  environment = "ue1"
  stage       = "teaching"
  name        = "default"

  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = true

  tags = { Protected = "true" }
}

module "nuke_bomber" {
  source = "../../../../masterpoint/terraform-aws-nuke-bomber"
  # source  = "masterpointio/nuke-bomber/aws"
  # version = "0.2.0"

  namespace   = "mp"
  environment = "ue1"
  stage       = "teaching"
  name        = "nuke-bomber"

  # Run every Sunday at 5am UTC
  schedule_expression = "cron(0 5 ? * SUN *)"

  command = ["-c", "/home/aws-nuke/nuke-config.yml", "--force", "--force-sleep", "3", "--no-dry-run"]
}