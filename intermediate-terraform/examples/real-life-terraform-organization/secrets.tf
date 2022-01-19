locals {
  secrets = yamldecode(data.sops_external.secrets.raw)
}
data "local_file" "secrets_yaml" {
  filename = "../config/secrets/secrets.yml"
}

data "sops_external" "secrets" {
  source     = data.local_file.secrets_yaml.content
  input_type = "yaml"
}
