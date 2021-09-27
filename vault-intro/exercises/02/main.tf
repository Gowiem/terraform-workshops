provider "vault" {
  address = "http://127.0.0.1:8201"

  # NOTE: The below is only necessary if `VAULT_TOKEN` is not set to your root token. We set that in excercise #1
  # token = <YOUR ROOT TOKEN>
}

resource "vault_generic_secret" "api_key" {
  path = "secret/api_key"
  data_json = jsonencode({ greeter = var.api_key })
}