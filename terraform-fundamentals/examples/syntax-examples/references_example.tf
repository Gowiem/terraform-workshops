## Resource Attribute Refence
###############################
resource "aws_security_group" "firewall" {
  name = "my-security-group"

  # ...
}

resource "aws_instance" "example" {
  # ...

  security_groups = [
    aws_security_group.firewall.id
  ]
}

## Data Source Reference
##########################

data "aws_vpc" "target_vpc" {
  id = "vpc-349781234509"
}

output "vpc_arn" {
  value       = data.aws_vpc.target_vpc.arn
  description = "The Amazon Resource Name of the target VPC."
}

## Module Output Refernece
############################
# This `rds_cluster` module defines outputs for `username` + `password`
module "database" {
  source = "./rds_cluster"
  # ...
}

# Don't ever do this in the real world ;)
resource "aws_s3_bucket_object" "rds_credentials" {
  bucket  = "tf-fundys-finn-mertens"
  key     = "rds_credentials.txt"
  content = "Username: ${module.database.username}\nPassword: ${module.database.password}"
}

## Provisioner Self Reference
###############################
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo The server has been created and its IP address is ${self.private_ip}"
  }
}
