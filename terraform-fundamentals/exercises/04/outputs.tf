output "other_project_bucket" {
  value = data.terraform_remote_state.other_project.outputs.bucket_name
}
