## Module Meta Arguments
#########################

module "cloudwatch_monitors" {
  source  = "masterpointio/monitor/aws"
  version = "0.11.0"

  providers = {
    aws_region_1 = aws.usw2
    aws_region_2 = aws.use1
  }
}


## `depends_on` Meta Argument
##############################

# depends_on for outputs is hardly ever used (I have never needed it once)
# More information:
# https://www.terraform.io/docs/language/values/outputs.html#depends_on-explicit-output-dependencies
output "instance_ip_addr" {
  value       = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."

  depends_on = [
    # Security group rule must be created before this IP address could
    # actually be used, otherwise the services will be unreachable.
    aws_security_group_rule.local_access,
  ]
}

# `depends_on` can also be used on resources + modules (module support added in 0.13)
data "aws_instance" "bastion" {
  filter {
    name   = "tag:Name"
    values = [module.bastion.instance_name]
  }

  depends_on = [module.bastion]
}

## Provider Meta Argument
##########################

provider "aws" {
  region = "us-west-2"
  alias  = "usw2"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2_in_east" {
  # ...
}

resource "aws_instance" "ec2_in_west" {
  # ...
  provider = aws.usw2
}


## Lifecycle Meta Argument
###########################

resource "aws_lambda_function" "lambda" {
  # ...

  lifecycle {
    ignore_changes = [last_modified, source_code_hash]
  }
}
