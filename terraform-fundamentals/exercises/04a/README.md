# Remote Backend: S3

This exercise represents a simple example of a remote backend. Most examples require deeper understanding of AWS,
but all we did here was create an AWS instance and store the state in S3 rather than locally. To do this we use a
`terraform` block. It has a deliberate error in it because we don't want Terraform to store an incorrect bucket
name in the `.terraform` subdir. Change as noted below:

```hcl
terraform {
  backend "s3" {
    bucket = "dws-di-* # change '*' to your student alias and add trailing quote
    key    = "state/remote-state"
        region = "us-east-2"
  }
}
```

We need to specify the S3 bucket which stores the state, and we can't use a variable or a local, so you'll need to
first edit `main.tf` to enter the actual name of your bucket. 

Now run `terraform apply` in your Cloud9 IDE. This will create an instance. (You might want to take note of the instance
ID which is shown in the EC2 console.)

Run `terraform plan` and confirm that Terraform says nothing needs to be done. You should see something like this:

```
data.aws_ami.ubuntu: Refreshing state...
aws_instance.web: Refreshing state... [id=INSTANCE_ID]
```

where `INSTANCE_ID` is the ID you noted above.

Now run the same exact code elsewhere, e.g., on your own local machine. you don't have terraform installed locally,
you can just `cd` into the `elsewhere` directory which has the exact same Terraform code in it (actually the files
in that directory are links to the code in the directory above, rather than copies).

Run `terraform plan` and confirm that Terraform says nothing needs to be done. If the state had been stored locally,
this could not be the case, but since the state is stored in an S3 bucket, it's being shared across both copies of
the Terraform project.

# Workspaces

Now let's go further with a simple example of workspaces. Remember that workspaces are just distinct copies of the
state. Rather than making our own copies, we'll let Terraform do it for us. 

Terraform always starts with a workspace called `default`. Let's create a new workspace and name it `sandbox`. To do
that we'll use this command

```
terraform workspace new sandox
```

You should see output like this:

```
Created and switched to workspace "sandbox"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

Now check out your `.terraform` directory to see what's different, and also check out your S3 bucket.

Re-run `terraform plan` and notice that Terraform wants to create an instance even though one already exists. This is
because the original instance was in the `default` workspace, but we're the `sandbox` workspace.

Go ahead and `terraform apply` to create a new instance and take note of the instance ID again.

Switch back to the `default` workspace and destroy its instance:

```
terraform workspace select default
terraform destroy
```

Confirm that the `sandbox` instance is still running on AWS.

Finally, switch back to the `sandbox` workspace and destroy its instance:

```
terraform workspace select sandbox
terraform destroy
```


