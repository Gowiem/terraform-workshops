## Cloud Provider Example
##########################
provider "aws" {
  region = "us-west-2"

  assume_role {
    role_arn = local.assume_role
  }
}

provider "aws" {
  alias  = "east"
  region = "us-east-2"
}

resource "aws_s3_bucket" "west" {
  name = "..."
  # ...
}

resource "aws_s3_bucket" "east" {
  name = "..."
  # ...
  provider = aws.east
  depends_on = [
    aws_s3_bucket.west
  ]
}

## Kubernetes Cluster Provider Example
#######################################

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

## Database Provider Examples
##############################

provider "postgresql" {
  alias     = "first_db"
  host      = "localhost"
  port      = var.oc_tunnel_port
  username  = local.secrets.rds_secrets.db_user
  password  = local.secrets.rds_secrets.db_pass
  superuser = false
}

provider "postgresql" {
  alias     = "other_db"
  host      = "localhost"
  port      = var.activate_tunnel_port
  username  = local.secrets.other_secrets.db_user
  password  = local.secrets.other_secrets.db_pass
  superuser = false
}

provider "rabbitmq" {
  endpoint = "https://localhost:4443"
  username = local.secrets.rabbit_secrets.user
  password = local.secrets.rabbit_secrets.pass
  insecure = true
}

provider "elasticsearch" {
  url                   = "https://localhost:9201"
  healthcheck           = false
  insecure              = true
  elasticsearch_version = "7.8.0"
}

## Other Examples
###################

provider "datadog" {
  api_key = local.global_secrets.datadog.api_key
  app_key = local.global_secrets.datadog.app_key
}

provider "github" {
  token        = local.admin_secrets.github.access_token
  organization = "masterpointio"
}
