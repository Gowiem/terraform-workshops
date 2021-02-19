output "project_table_arn" {
  value = module.dynamodb.table_arn
}

output "project_keys" {
  value = module.ec2.keys
}
