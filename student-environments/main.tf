locals {
  config_yaml = yamldecode(file("${path.root}/config/${terraform.workspace}.yaml"))

  class_level    = local.config_yaml.class_level
  link_to_slides = local.config_yaml.link_to_slides
  link_to_survey = local.config_yaml.link_to_survey

  # students is a map of student names to student info objects
  # Example: { finn_mertens: { name: "Finn Mertens", email: "finn@masterpoint.io", alias: "finn-mertens" }, ... }
  students = { for s in local.config_yaml.students :
    replace(lower(s.name), " ", "_") => merge(s, {
      alias = replace(lower(s.name), " ", "-")
    })
  }
}

resource "random_shuffle" "region" {
  for_each = local.students

  input        = ["us-west-2", "us-east-2"]
  result_count = 1
}

resource "aws_s3_bucket" "student_buckets" {
  for_each      = local.students
  bucket        = "tf-${local.class_level}-${each.value.alias}"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_account_password_policy" "students" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = false
  allow_users_to_change_password = true
}

resource "aws_iam_user" "students" {
  for_each      = local.students
  name          = each.value.email
  force_destroy = true
}

resource "aws_iam_access_key" "students" {
  for_each = local.students
  user     = aws_iam_user.students[each.key].name
}

data "local_file" "pgp_key" {
  filename = "${path.module}/pub_keys/${var.pgp_key_filename}"
}

resource "aws_iam_user_login_profile" "students" {
  for_each                = local.students
  user                    = aws_iam_user.students[each.key].name
  password_length         = 10
  pgp_key                 = data.local_file.pgp_key.content
  password_reset_required = false
}

resource "aws_iam_policy" "student_bucket_access" {
  for_each    = local.students
  name        = "${each.value.alias}-StudentBucketAccess"
  description = "Allowing student access to their own bucket"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowBase",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowListMyBucket",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::tf-${local.class_level}-${each.value.alias}",
                "arn:aws:s3:::tf-${local.class_level}-${each.value.alias}-*"
            ]
        },
        {
            "Sid": "AllowAllInMyBucket",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
              "arn:aws:s3:::tf-${local.class_level}-${each.value.alias}/*",
              "arn:aws:s3:::tf-${local.class_level}-${each.value.alias}-*/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "student_ec2_access" {
  name        = "StudentEC2Access-${terraform.workspace}"
  description = "Allowing student access to EC2 accordingly"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllOnEC2",
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "OnlyAllowCertainInstanceTypesToBeCreated",
            "Effect": "Deny",
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "ForAnyValue:StringNotLike": {
                    "ec2:InstanceType": [
                        "*.nano",
                        "*.small",
                        "*.micro"
                    ]
                }
            }
        },
        {
            "Sid": "AllowAllELB",
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Sid": "AllowAllAutoscaling",
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy" "student_credentials_access" {
  name        = "StudentIAMCredentialsAccess-${terraform.workspace}"
  description = "Allowing student to rotate and manage their own credentials"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:ListUsers",
                "iam:GetAccountPasswordPolicy"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:*AccessKey*",
                "iam:ChangePassword",
                "iam:GetUser",
                "iam:*ServiceSpecificCredential*",
                "iam:*SigningCertificate*"
            ],
            "Resource": ["arn:aws:iam::*:user/$${aws:username}"]
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "student_bucket_access" {
  for_each   = local.students
  user       = aws_iam_user.students[each.key].name
  policy_arn = aws_iam_policy.student_bucket_access[each.key].arn
}

resource "aws_iam_user_policy_attachment" "student_ec2_access" {
  for_each   = local.students
  user       = aws_iam_user.students[each.key].name
  policy_arn = aws_iam_policy.student_ec2_access.arn
}

resource "aws_iam_user_policy_attachment" "student_credentials_access" {
  for_each   = local.students
  user       = aws_iam_user.students[each.key].name
  policy_arn = aws_iam_policy.student_credentials_access.arn
}

resource "aws_iam_user_policy_attachment" "cloud9_user_access" {
  for_each   = local.students
  user       = aws_iam_user.students[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9User"
}

resource "aws_iam_user_policy_attachment" "dynamodb_user_access" {
  for_each   = local.students
  user       = aws_iam_user.students[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "template_file" "message_script" {
  for_each = !var.email_enabled ? local.students : {}

  template = file("${path.module}/templates/message.sh.tpl")
  vars = {
    encrypted_password = aws_iam_user_login_profile.students[each.key].encrypted_password
    student_email      = each.value.email
    student_alias      = each.value.alias
    student_region     = random_shuffle.region[each.key].result[0]
    link_to_slides     = local.link_to_slides
    link_to_survey     = local.link_to_survey
  }
}

resource "null_resource" "message_files" {
  for_each = !var.email_enabled ? local.students : {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = data.template_file.message_script[each.key].rendered
  }
}


data "template_file" "email_script" {
  for_each = var.email_enabled ? local.students : {}

  template = file("${path.module}/templates/email.sh.tpl")
  vars = {
    encrypted_password = aws_iam_user_login_profile.students[each.key].encrypted_password
    student_email      = each.value.email
    student_alias      = each.value.alias
    student_region     = random_shuffle.region[each.key].result[0]
    link_to_slides     = local.link_to_slides
    link_to_survey     = local.link_to_survey
  }
}

resource "null_resource" "email_students" {
  for_each = var.email_enabled ? local.students : {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = data.template_file.email_script[each.key].rendered
  }
}
