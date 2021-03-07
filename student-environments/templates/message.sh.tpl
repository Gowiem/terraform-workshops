#!/usr/bin/env bash
set -euxo pipefail

PASSWORD=$(echo '${encrypted_password}' | base64 --decode | gpg -d)

EMAIL_BODY=$(cat <<-EOT
Hey there!

Here is the AWS account and other course info --

AWS Console URL: https://masterpoint-teaching.signin.aws.amazon.com/console
AWS Console Account Alias: masterpoint-teaching
AWS Console Username: ${student_email}
AWS Console Password: $PASSWORD
AWS Region for Exercise 11: ${student_region}
Your Student Alias: ${student_alias}

Repo: https://github.com/Gowiem/terraform-workshops
Link to the slides: ${link_to_slides}
Link to personal feedback survery: ${link_to_survey}
Instructor email: matt@masterpoint.io

Side Note: This message was generated with Terraform! Check out 'student-environments/main.tf' after the class for a peak behind the covers 😎
EOT
)

echo "$EMAIL_BODY" >> ./messages/${student_alias}.txt