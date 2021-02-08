
## Terraform Registry Source
#############################
module "datadog_monitors" {
  source  = "cloudposse/monitor/datadog"
  version = "0.11.0"

  # ...
}

## Git Source
##############
module "bastion" {
  source = "git::https://github.com/masterpointio/terraform-aws-ssm-agent.git?ref=tags/0.8.0"

  # ...
}

module "consul" {
  source = "bitbucket.org/hashicorp/terraform-consul-aws"

  # ...
}

## AWS S3 Source
#################
module "rds_cluster" {
  source = "s3::https://s3-eu-west-1.amazonaws.com/examplecorp-terraform-modules/rds_cluster_v0-10-0.zip"

  # ...
}

## HTTP Source
###############
module "vpc" {
  source = "https://example.com/vpc-module.zip"
}
