provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
}

provider "aws" {
  alias  = "oregon"
  region = "us-west-2"
}

module "ue1_vpc" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.27.0"

  namespace   = "mp"
  environment = "ue1"
  stage       = "teaching"
  name        = "default"
  cidr_block  = "10.20.0.0/16"

  tags = { Protected = "true" }
}

module "ue1_subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.39.5"

  namespace   = "mp"
  environment = "ue1"
  stage       = "teaching"
  name        = "default"

  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_id              = module.ue1_vpc.vpc_id
  igw_id              = module.ue1_vpc.igw_id
  cidr_block          = module.ue1_vpc.vpc_cidr_block
  nat_gateway_enabled = true

  tags = { Protected = "true" }
}

module "ue2_vpc" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.27.0"

  namespace   = "mp"
  environment = "ue2"
  stage       = "teaching"
  name        = "default"
  cidr_block  = "10.20.0.0/16"

  tags = { Protected = "true" }

  providers = {
    aws = aws.ohio
  }
}

module "ue2_subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.39.5"

  namespace   = "mp"
  environment = "ue2"
  stage       = "teaching"
  name        = "default"

  availability_zones  = ["us-east-2a", "us-east-2b", "us-east-2c"]
  vpc_id              = module.ue2_vpc.vpc_id
  igw_id              = module.ue2_vpc.igw_id
  cidr_block          = module.ue2_vpc.vpc_cidr_block
  nat_gateway_enabled = true

  tags = { Protected = "true" }

  providers = {
    aws = aws.ohio
  }
}

module "uw2_vpc" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.27.0"

  namespace   = "mp"
  environment = "uw2"
  stage       = "teaching"
  name        = "default"
  cidr_block  = "10.20.0.0/16"

  tags = { Protected = "true" }

  providers = {
    aws = aws.oregon
  }
}

module "uw2_subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.39.5"

  namespace   = "mp"
  environment = "uw2"
  stage       = "teaching"
  name        = "default"

  availability_zones  = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_id              = module.uw2_vpc.vpc_id
  igw_id              = module.uw2_vpc.igw_id
  cidr_block          = module.uw2_vpc.vpc_cidr_block
  nat_gateway_enabled = true

  tags = { Protected = "true" }

  providers = {
    aws = aws.oregon
  }
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
