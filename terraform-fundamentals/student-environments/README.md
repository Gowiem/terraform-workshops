# Student Environments

This root module creates accounts, a bucket, and permissions for all students in the course. It emails all important information for the course to the students.

A few important notes:

1. The configuration for the students is driven through a YAML file provided in the config folder. You can see the `testing.yaml` file as an example.
1. It's expected that this project is applied locally and the applier has [Mac OSX `mail` setup on their machine](https://github.com/roubles/postfixconf).