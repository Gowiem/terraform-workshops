provider "vault" {
  address = "http://127.0.0.1:8201"

  # NOTE: The below is only necessary if `VAULT_TOKEN` is not set to your root token. We set that in excercise #1
  # token = <YOUR ROOT TOKEN>
}

variable "legacy_password" {
  type        = string
  description = "The password that is that is required for some legacy system that the application accesses."
}

resource "vault_mount" "kv_v2" {
  path        = "application"
  type        = "kv-v2"
  description = "KV v2 for the Application's static secrets"
}

resource "random_password" "api_key" {
  length           = 32
  special          = true
  override_special = "_%@"
}

resource "vault_generic_secret" "api_key" {
  path = "application/api_key"
  data_json = jsonencode({
    value        = random_password.api_key.result
    generated_by = "Terraform"
  })

  depends_on = [
    vault_mount.kv_v2
  ]
}

resource "vault_generic_secret" "legacy_password" {
  path = "application/legacy_password"
  data_json = jsonencode({ value = var.legacy_password })

  depends_on = [
    vault_mount.kv_v2
  ]
}

resource "vault_policy" "application_policy" {
  name = "application_policy"

  policy = <<EOT
path "secret/api_key" {
  capabilities = ["read"]
}

path "secret/legacy_password" {
  capabilities = ["read"]
}
EOT
}

