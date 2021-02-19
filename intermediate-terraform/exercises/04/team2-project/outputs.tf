output "team1_key_pair_id" {
  value = data.terraform_remote_state.team1.outputs.my_key_pair_id
}
