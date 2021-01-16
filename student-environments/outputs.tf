output "students" {
  value = {
    for s, info in local.students :
    s => merge(info, {
      region = random_shuffle.region[s].result[0]
    })
  }
}

output "passwords" {
  value = {
    for key, student_info in local.students :
    key => aws_iam_user_login_profile.students[key].encrypted_password
  }
}

output "access_keys" {
  value = {
    for key, student_info in local.students :
    key => aws_iam_access_key.students[key].id
  }
}

output "secret_keys" {
  value = {
    for key, student_info in local.students :
    key => aws_iam_access_key.students[key].secret
  }
}
