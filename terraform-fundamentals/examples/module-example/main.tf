module "example" {
  source = "./hello"
  name   = "Class"
}

output "executed_command_from_module" {
  value       = module.example.executed_command
  description = "The command that the module executed."
}
