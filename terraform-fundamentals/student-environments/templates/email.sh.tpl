#!/usr/bin/env bash
set -euxo pipefail

PASSWORD=$(echo '${encrypted_password}' | base64 --decode | gpg -d)

EMAIL_BODY=$(cat <<-EOT
Hey there!

Here is the AWS account and other course info --

AWS Console URL: https://masterpoint-teaching.signin.aws.amazon.com/console
AWS Console Username: ${student_email}
AWS Console Password: $PASSWORD
AWS Region for Exercise 11: ${student_region}

Repo: https://github.com/Gowiem/terraform-workshops
Link to the slides: http://bit.ly/TODO
Instructor email: matt@masterpoint.io

Side Note: This email was generated with Terraform! Check out 'student-environments/main.tf' after the class for a peak behind the covers 😎

- Matt Gowie
EOT
)

echo "$EMAIL_BODY" | mail -s 'Your Terraform Course Info!' ${student_email}