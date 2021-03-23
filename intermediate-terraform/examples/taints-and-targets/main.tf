variable "greetee" {
  default     = "world"
  type        = string
  description = "The object or person we're saying hello to"
}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo 'hello'"
  }
}

resource "null_resource" "world" {
  provisioner "local-exec" {
    command = "echo '${var.greetee}!'"
  }
}


# 1. Taint command:
# terraform taint null_resource.world
# terraform plan -out run.plan
  # terraform apply run.plan
#
# 2. Targetted destroy command:
# terraform destroy -target null_resource.world
# terraform plan -out run.plan
# terraform apply run.plan
#
# 3. Targetted plan / apply command:
# terraform plan -target null_resource.hello -out run.plan
# terraform apply run.plan
