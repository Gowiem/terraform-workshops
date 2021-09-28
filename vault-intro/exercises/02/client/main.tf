provider "vault" {
  address = "http://127.0.0.1:8201"

  # NOTE: The below is only necessary if `VAULT_TOKEN` is not set to your root token. We set that in excercise #1
  # token = <YOUR ROOT TOKEN>
}

data "vault_generic_secret" "legacy_password" {
  path = "application/legacy_password"
}

data "vault_generic_secret" "api_key" {
  path = "application/api_key"
}

output "legacy_password" {
  value       = data.vault_generic_secret.legacy_password.data.value
  description = "The password for the legacy system that the application accesses."
}

output "api_key" {
  value       = data.vault_generic_secret.api_key.data.value
  description = "The primary api_key for the application."
}
