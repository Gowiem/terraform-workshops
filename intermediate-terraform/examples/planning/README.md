# Some more complex planning examples

* The pitfalls of not using the plan file approach, and what Terraform has done more recently to reduce these pitfalls
* Plan files, and outdated plan files
* Some approaches to more easily see why a plan file has become outdated

First, assume the roll of jane, and we'll "pull" source code from our terraform project repo into our workspace

```
./pull.sh jane
```

jane now is working from a local workstation with a current version of the terraform source. jane will init her new workspace and then apply...


```
cd ./jane
terraform init
terraform apply
...
aws_instance.instance: Creating...
aws_instance.instance: Still creating... [10s elapsed]
aws_instance.instance: Still creating... [20s elapsed]
aws_instance.instance: Still creating... [30s elapsed]
aws_instance.instance: Creation complete after 36s [id=i-0ac3bc004111f203b]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

infrastructure initially created

now to tim, we'll say he wants to make a change, so he's going to "pull" from source to do so

```
cd ../
./pull.sh tim
cd ./tim
terraform init
cd ../
```

We'll make a change to the instance type, changing to t2.medium and apply

```
resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
- instance_type = "t2.micro"
+ instance_type = "t2.medium"
  tags = {
    Name = "examples-planning"
  }
}
```

Meanwhile jane just made the following change to her source locally and wants to apply

```
resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
-   Name = "examples-planning"
+   Name = "examples-planning-01"
  }
}
```

So, just changing the tag name on the instance, she happens to run her apply command before tim finishes doing his apply, so let's mimic that

```
cd ./jane
terraform apply
...
data.aws_ami.ubuntu: Refreshing state...
aws_instance.instance: Refreshing state... [id=i-0ac3bc004111f203b]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.instance will be updated in-place
  ~ resource "aws_instance" "instance" {
        ami                          = "ami-08e606e4fe6e7a28f"
        arn                          = "arn:aws:ec2:us-west-2:946320133426:instance/i-0ac3bc004111f203b"
        associate_public_ip_address  = true
        availability_zone            = "us-west-2c"
        cpu_core_count               = 1
        cpu_threads_per_core         = 1
        disable_api_termination      = false
        ebs_optimized                = false
        get_password_data            = false
        hibernation                  = false
        id                           = "i-0ac3bc004111f203b"
        instance_state               = "running"
        instance_type                = "t2.micro"
        ipv6_address_count           = 0
        ipv6_addresses               = []
        monitoring                   = false
        primary_network_interface_id = "eni-0b6e74ed107cb82a7"
        private_dns                  = "ip-172-31-13-76.us-west-2.compute.internal"
        private_ip                   = "172.31.13.76"
        public_dns                   = "ec2-34-211-142-182.us-west-2.compute.amazonaws.com"
        public_ip                    = "34.211.142.182"
        security_groups              = [
            "default",
        ]
        source_dest_check            = true
        subnet_id                    = "subnet-490b1913"
      ~ tags                         = {
          ~ "Name" = "examples-planning" -> "examples-planning-01"
        }
        tenancy                      = "default"
        volume_tags                  = {}
        vpc_security_group_ids       = [
            "sg-4ee26102",
        ]

        credit_specification {
            cpu_credits = "standard"
        }

        metadata_options {
            http_endpoint               = "enabled"
            http_put_response_hop_limit = 1
            http_tokens                 = "optional"
        }

        root_block_device {
            delete_on_termination = true
            device_name           = "/dev/sda1"
            encrypted             = false
            iops                  = 100
            volume_id             = "vol-03933a48ea39d739c"
            volume_size           = 8
            volume_type           = "gp2"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.


  Enter a value:
```

jane gets pulled away for something for 10 minutes before she has a chance to accept this plan and actually apply it. Meanwhile, tim is actually applying his change

```
cd ../tim
terraform apply
...
data.aws_ami.ubuntu: Refreshing state...
aws_instance.instance: Refreshing state... [id=i-0ac3bc004111f203b]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.instance will be updated in-place
  ~ resource "aws_instance" "instance" {
        ami                          = "ami-08e606e4fe6e7a28f"
        arn                          = "arn:aws:ec2:us-west-2:946320133426:instance/i-0ac3bc004111f203b"
        associate_public_ip_address  = true
        availability_zone            = "us-west-2c"
        cpu_core_count               = 1
        cpu_threads_per_core         = 1
        disable_api_termination      = false
        ebs_optimized                = false
        get_password_data            = false
        hibernation                  = false
        id                           = "i-0ac3bc004111f203b"
        instance_state               = "running"
      ~ instance_type                = "t2.micro" -> "t2.medium"
        ipv6_address_count           = 0
        ipv6_addresses               = []
        monitoring                   = false
        primary_network_interface_id = "eni-0b6e74ed107cb82a7"
        private_dns                  = "ip-172-31-13-76.us-west-2.compute.internal"
        private_ip                   = "172.31.13.76"
        public_dns                   = "ec2-34-211-142-182.us-west-2.compute.amazonaws.com"
        public_ip                    = "34.211.142.182"
        security_groups              = [
            "default",
        ]
        source_dest_check            = true
        subnet_id                    = "subnet-490b1913"
        tags                         = {
            "Name" = "examples-planning"
        }
        tenancy                      = "default"
        volume_tags                  = {}
        vpc_security_group_ids       = [
            "sg-4ee26102",
        ]

        credit_specification {
            cpu_credits = "standard"
        }

        metadata_options {
            http_endpoint               = "enabled"
            http_put_response_hop_limit = 1
            http_tokens                 = "optional"
        }

        root_block_device {
            delete_on_termination = true
            device_name           = "/dev/sda1"
            encrypted             = false
            iops                  = 100
            volume_id             = "vol-03933a48ea39d739c"
            volume_size           = 8
            volume_type           = "gp2"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.instance: Modifying... [id=i-0ac3bc004111f203b]
aws_instance.instance: Still modifying... [id=i-0ac3bc004111f203b, 10s elapsed]
aws_instance.instance: Still modifying... [id=i-0ac3bc004111f203b, 20s elapsed]
aws_instance.instance: Still modifying... [id=i-0ac3bc004111f203b, 30s elapsed]
aws_instance.instance: Modifications complete after 38s [id=i-0ac3bc004111f203b]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

tim has successfully updated the ec2 instance type to t2.medium. jane makes it back to what she was doing and is ready to say yes to her plan which just included a change to a tag

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.instance: Modifying... [id=i-0ac3bc004111f203b]
aws_instance.instance: Modifications complete after 3s [id=i-0ac3bc004111f203b]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

So, will jane's actions have reverted tim's instance type changes? Let's do a state pull to see if it did:


```
terraform state pull
...
"instance_type": "t2.medium",
...
"tags": {
  "Name": "examples-planning-01"
},
```

Ah, so everything is as it should be! A plan out file wasn't strictly needed in this case where it would've been in the past. Terraform's auto-running of plan and force acceptance of it on apply is essentially does the same thing as a plan out file, and this is a relatively new flow for the tool. It will "cache" the plan presented to the user much like a plan out file, and when the user says "yes", only this plan will be applied.

The plan out file is still a best practice when using `terraform plan` itself, so let's go back through the above from a different route and see the actual pitfall that still exists with this

```
terraform destroy
...
cd ../
./pull.sh tim
./pull.sh jane
cd ./jane
terraform apply
...
aws_instance.instance: Creating...
aws_instance.instance: Still creating... [10s elapsed]
aws_instance.instance: Still creating... [20s elapsed]
aws_instance.instance: Creation complete after 24s [id=i-0ca5be7bc21a9342d]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
jane's workflow in this scenario is one of running `terraform plan` to see what changes her config would make and then `terraform apply -auto-approve`, which has historically been somewhat common. The idea of the `apply` command enforcing the need to accept the plan is relatively new. But this workflow of jane's represents something of a more-normal workflow in the past. So, let's see why it can fail.

jane has just created the infrastructure anew. She realizes she needs to change the tag name, so she does so in your local repo clone

```
resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
-   Name = "examples-planning"
+   Name = "examples-planning-01"
  }
}
```

she runs her plan

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.instance will be updated in-place
  ~ resource "aws_instance" "instance" {
        ami                          = "ami-08e606e4fe6e7a28f"
        arn                          = "arn:aws:ec2:us-west-2:946320133426:instance/i-0ca5be7bc21a9342d"
        associate_public_ip_address  = true
        availability_zone            = "us-west-2c"
        cpu_core_count               = 1
        cpu_threads_per_core         = 1
        disable_api_termination      = false
        ebs_optimized                = false
        get_password_data            = false
        hibernation                  = false
        id                           = "i-0ca5be7bc21a9342d"
        instance_state               = "running"
        instance_type                = "t2.micro"
        ipv6_address_count           = 0
        ipv6_addresses               = []
        monitoring                   = false
        primary_network_interface_id = "eni-0af8ba5c2a909e4a9"
        private_dns                  = "ip-172-31-3-214.us-west-2.compute.internal"
        private_ip                   = "172.31.3.214"
        public_dns                   = "ec2-34-214-164-42.us-west-2.compute.amazonaws.com"
        public_ip                    = "34.214.164.42"
        security_groups              = [
            "default",
        ]
        source_dest_check            = true
        subnet_id                    = "subnet-490b1913"
      ~ tags                         = {
          ~ "Name" = "examples-planning" -> "examples-planning-01"
        }
        tenancy                      = "default"
        volume_tags                  = {}
        vpc_security_group_ids       = [
            "sg-4ee26102",
        ]

        credit_specification {
            cpu_credits = "standard"
        }

        metadata_options {
            http_endpoint               = "enabled"
            http_put_response_hop_limit = 1
            http_tokens                 = "optional"
        }

        root_block_device {
            delete_on_termination = true
            device_name           = "/dev/sda1"
            encrypted             = false
            iops                  = 100
            volume_id             = "vol-06e37b177f7245788"
            volume_size           = 8
            volume_type           = "gp2"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

great, just the tag change. jane doesn't even get pulled away in this scenario. Simply, tim happens to be applying his instance type change at the exact moment that jane's plan output was presented to her

```
resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
- instance_type = "t2.micro"
+ instance_type = "t2.medium"
  tags = {
    Name = "examples-planning"
  }
}
```

```
cd ../tim
terraform apply
...
data.aws_ami.ubuntu: Refreshing state...
aws_instance.instance: Refreshing state... [id=i-0ca5be7bc21a9342d]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.instance will be updated in-place
  ~ resource "aws_instance" "instance" {
        ami                          = "ami-08e606e4fe6e7a28f"
        arn                          = "arn:aws:ec2:us-west-2:946320133426:instance/i-0ca5be7bc21a9342d"
        associate_public_ip_address  = true
        availability_zone            = "us-west-2c"
        cpu_core_count               = 1
        cpu_threads_per_core         = 1
        disable_api_termination      = false
        ebs_optimized                = false
        get_password_data            = false
        hibernation                  = false
        id                           = "i-0ca5be7bc21a9342d"
        instance_state               = "running"
      ~ instance_type                = "t2.micro" -> "t2.medium"
        ipv6_address_count           = 0
        ipv6_addresses               = []
        monitoring                   = false
        primary_network_interface_id = "eni-0af8ba5c2a909e4a9"
        private_dns                  = "ip-172-31-3-214.us-west-2.compute.internal"
        private_ip                   = "172.31.3.214"
        public_dns                   = "ec2-34-214-164-42.us-west-2.compute.amazonaws.com"
        public_ip                    = "34.214.164.42"
        security_groups              = [
            "default",
        ]
        source_dest_check            = true
        subnet_id                    = "subnet-490b1913"
        tags                         = {
            "Name" = "examples-planning"
        }
        tenancy                      = "default"
        volume_tags                  = {}
        vpc_security_group_ids       = [
            "sg-4ee26102",
        ]

        credit_specification {
            cpu_credits = "standard"
        }

        metadata_options {
            http_endpoint               = "enabled"
            http_put_response_hop_limit = 1
            http_tokens                 = "optional"
        }

        root_block_device {
            delete_on_termination = true
            device_name           = "/dev/sda1"
            encrypted             = false
            iops                  = 100
            volume_id             = "vol-06e37b177f7245788"
            volume_size           = 8
            volume_type           = "gp2"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.instance: Modifying... [id=i-0ca5be7bc21a9342d]
aws_instance.instance: Still modifying... [id=i-0ca5be7bc21a9342d, 10s elapsed]
aws_instance.instance: Still modifying... [id=i-0ca5be7bc21a9342d, 20s elapsed]
aws_instance.instance: Still modifying... [id=i-0ca5be7bc21a9342d, 30s elapsed]
aws_instance.instance: Modifications complete after 39s [id=i-0ca5be7bc21a9342d]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

meanwhile, seconds later, jane runs her `terraform apply -auto-approve` b/c how could anything happen differently than what my plan told me?

```
cd ../jane
terraform apply -auto-approve
...
data.aws_ami.ubuntu: Refreshing state...
aws_instance.instance: Refreshing state... [id=i-0ca5be7bc21a9342d]
aws_instance.instance: Modifying... [id=i-0ca5be7bc21a9342d]
aws_instance.instance: Still modifying... [id=i-0ca5be7bc21a9342d, 10s elapsed]
aws_instance.instance: Still modifying... [id=i-0ca5be7bc21a9342d, 20s elapsed]
aws_instance.instance: Still modifying... [id=i-0ca5be7bc21a9342d, 30s elapsed]
aws_instance.instance: Still modifying... [id=i-0ca5be7bc21a9342d, 40s elapsed]
aws_instance.instance: Still modifying... [id=i-0ca5be7bc21a9342d, 50s elapsed]
aws_instance.instance: Modifications complete after 55s [id=i-0ca5be7bc21a9342d]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

```
terraform state pull
...
"instance_type": "t2.micro",
...
"tags": {
  "Name": "examples-planning-01"
},
```

Well, our tag change made it, but uh oh, we overwrote tim's change. Using a plan out file would've prevented this, so let's see that in action

```
terraform destroy
...
cd ../
./pull.sh tim
./pull.sh jane
```

## Plan out files and outdated plan files

```
cd ./jane
terraform apply
...
aws_instance.instance: Creating...
aws_instance.instance: Still creating... [10s elapsed]
aws_instance.instance: Still creating... [20s elapsed]
aws_instance.instance: Creation complete after 24s [id=i-0ca5be7bc21a9342d]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

OK, so we're back with our freshly-created infrastructure, we'll go through almost the exact same flow of changes again, first jane does a plan after changing the tag name of the instance, but now we're going to use a plan out file


```
terraform plan -out=plan.out
...
data.aws_ami.ubuntu: Refreshing state...
aws_instance.instance: Refreshing state... [id=i-0d02d00e96e27d752]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.instance will be updated in-place
  ~ resource "aws_instance" "instance" {
        ami                          = "ami-08e606e4fe6e7a28f"
        arn                          = "arn:aws:ec2:us-west-2:946320133426:instance/i-0d02d00e96e27d752"
        associate_public_ip_address  = true
        availability_zone            = "us-west-2c"
        cpu_core_count               = 1
        cpu_threads_per_core         = 1
        disable_api_termination      = false
        ebs_optimized                = false
        get_password_data            = false
        hibernation                  = false
        id                           = "i-0d02d00e96e27d752"
        instance_state               = "running"
        instance_type                = "t2.micro"
        ipv6_address_count           = 0
        ipv6_addresses               = []
        monitoring                   = false
        primary_network_interface_id = "eni-0eec1907e7f481c89"
        private_dns                  = "ip-172-31-5-136.us-west-2.compute.internal"
        private_ip                   = "172.31.5.136"
        public_dns                   = "ec2-34-216-54-147.us-west-2.compute.amazonaws.com"
        public_ip                    = "34.216.54.147"
        security_groups              = [
            "default",
        ]
        source_dest_check            = true
        subnet_id                    = "subnet-490b1913"
      ~ tags                         = {
          ~ "Name" = "examples-planning" -> "examples-planning-01"
        }
        tenancy                      = "default"
        volume_tags                  = {}
        vpc_security_group_ids       = [
            "sg-4ee26102",
        ]

        credit_specification {
            cpu_credits = "standard"
        }

        metadata_options {
            http_endpoint               = "enabled"
            http_put_response_hop_limit = 1
            http_tokens                 = "optional"
        }

        root_block_device {
            delete_on_termination = true
            device_name           = "/dev/sda1"
            encrypted             = false
            iops                  = 100
            volume_id             = "vol-0d555eef76125a3db"
            volume_size           = 8
            volume_type           = "gp2"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

This plan was saved to: plan.out

To perform exactly these actions, run the following command to apply:
    terraform apply "plan.out"
```

back to tim, so we'll put his changes in place before jane actually applies hers

```
cd ../tim
terraform apply
...
data.aws_ami.ubuntu: Refreshing state...
aws_instance.instance: Refreshing state... [id=i-0d02d00e96e27d752]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.instance will be updated in-place
  ~ resource "aws_instance" "instance" {
        ami                          = "ami-08e606e4fe6e7a28f"
        arn                          = "arn:aws:ec2:us-west-2:946320133426:instance/i-0d02d00e96e27d752"
        associate_public_ip_address  = true
        availability_zone            = "us-west-2c"
        cpu_core_count               = 1
        cpu_threads_per_core         = 1
        disable_api_termination      = false
        ebs_optimized                = false
        get_password_data            = false
        hibernation                  = false
        id                           = "i-0d02d00e96e27d752"
        instance_state               = "running"
      ~ instance_type                = "t2.micro" -> "t2.medium"
        ipv6_address_count           = 0
        ipv6_addresses               = []
        monitoring                   = false
        primary_network_interface_id = "eni-0eec1907e7f481c89"
        private_dns                  = "ip-172-31-5-136.us-west-2.compute.internal"
        private_ip                   = "172.31.5.136"
        public_dns                   = "ec2-34-216-54-147.us-west-2.compute.amazonaws.com"
        public_ip                    = "34.216.54.147"
        security_groups              = [
            "default",
        ]
        source_dest_check            = true
        subnet_id                    = "subnet-490b1913"
        tags                         = {
            "Name" = "examples-planning"
        }
        tenancy                      = "default"
        volume_tags                  = {}
        vpc_security_group_ids       = [
            "sg-4ee26102",
        ]

        credit_specification {
            cpu_credits = "standard"
        }

        metadata_options {
            http_endpoint               = "enabled"
            http_put_response_hop_limit = 1
            http_tokens                 = "optional"
        }

        root_block_device {
            delete_on_termination = true
            device_name           = "/dev/sda1"
            encrypted             = false
            iops                  = 100
            volume_id             = "vol-0d555eef76125a3db"
            volume_size           = 8
            volume_type           = "gp2"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.instance: Modifying... [id=i-0d02d00e96e27d752]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 10s elapsed]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 20s elapsed]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 30s elapsed]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 40s elapsed]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 50s elapsed]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 1m0s elapsed]
aws_instance.instance: Modifications complete after 1m5s [id=i-0d02d00e96e27d752]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

the instance type change is in place, and now jane happens to be running her apply of the plan file seconds later

```
cd ../jane
terraform apply plan.out

Error: Saved plan is stale

The given plan file can no longer be applied because the state was changed by
another operation after the plan was created.
```

Ah! Something in tim's changes now makes jane's plan stale (outdated) and she must redo her option.

The real takeaway from this, at this level, is to just know that this is a protection against clobbering changes unknowingly. When we see this, we simply know that we need to generate a plan (file) again, so let's do that:

```
terraform plan -out=plan.out
terraform show plan.out

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.instance will be updated in-place
  ~ resource "aws_instance" "instance" {
        ami                          = "ami-08e606e4fe6e7a28f"
        arn                          = "arn:aws:ec2:us-west-2:946320133426:instance/i-0d02d00e96e27d752"
        associate_public_ip_address  = true
        availability_zone            = "us-west-2c"
        cpu_core_count               = 2
        cpu_threads_per_core         = 1
        disable_api_termination      = false
        ebs_optimized                = false
        get_password_data            = false
        hibernation                  = false
        id                           = "i-0d02d00e96e27d752"
        instance_state               = "running"
      ~ instance_type                = "t2.medium" -> "t2.micro"
        ipv6_address_count           = 0
        ipv6_addresses               = []
        monitoring                   = false
        primary_network_interface_id = "eni-0eec1907e7f481c89"
        private_dns                  = "ip-172-31-5-136.us-west-2.compute.internal"
        private_ip                   = "172.31.5.136"
        public_dns                   = "ec2-34-208-7-1.us-west-2.compute.amazonaws.com"
        public_ip                    = "34.208.7.1"
        security_groups              = [
            "default",
        ]
        source_dest_check            = true
        subnet_id                    = "subnet-490b1913"
      ~ tags                         = {
          ~ "Name" = "examples-planning" -> "examples-planning-01"
        }
        tenancy                      = "default"
        volume_tags                  = {}
        vpc_security_group_ids       = [
            "sg-4ee26102",
        ]

        credit_specification {
            cpu_credits = "standard"
        }

        metadata_options {
            http_endpoint               = "enabled"
            http_put_response_hop_limit = 1
            http_tokens                 = "optional"
        }

        root_block_device {
            delete_on_termination = true
            device_name           = "/dev/sda1"
            encrypted             = false
            iops                  = 100
            volume_id             = "vol-0d555eef76125a3db"
            volume_size           = 8
            volume_type           = "gp2"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

We see that there's some indication that jane's code is outdated, at the very least some changes have actually been applied to the infrastructure from elsewhere. Our plan now shows that, gives us a good indication that we need to do something like pull in new changes from source, do some checks over the cubicles with your team, whatever might be appropriate to make sense of it all.

In our case, jane will simply update her code to match what seemingly has been an intended change elsewhere:

```
resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  tags = {
    Name = "examples-planning-01"
  }
}
```

Then rerun our plan with an out file again:

```
terraform plan -out=plan.out
terraform show plan.out

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.instance will be updated in-place
  ~ resource "aws_instance" "instance" {
        ami                          = "ami-08e606e4fe6e7a28f"
        arn                          = "arn:aws:ec2:us-west-2:946320133426:instance/i-0d02d00e96e27d752"
        associate_public_ip_address  = true
        availability_zone            = "us-west-2c"
        cpu_core_count               = 2
        cpu_threads_per_core         = 1
        disable_api_termination      = false
        ebs_optimized                = false
        get_password_data            = false
        hibernation                  = false
        id                           = "i-0d02d00e96e27d752"
        instance_state               = "running"
        instance_type                = "t2.medium"
        ipv6_address_count           = 0
        ipv6_addresses               = []
        monitoring                   = false
        primary_network_interface_id = "eni-0eec1907e7f481c89"
        private_dns                  = "ip-172-31-5-136.us-west-2.compute.internal"
        private_ip                   = "172.31.5.136"
        public_dns                   = "ec2-34-208-7-1.us-west-2.compute.amazonaws.com"
        public_ip                    = "34.208.7.1"
        security_groups              = [
            "default",
        ]
        source_dest_check            = true
        subnet_id                    = "subnet-490b1913"
      ~ tags                         = {
          ~ "Name" = "examples-planning" -> "examples-planning-01"
        }
        tenancy                      = "default"
        volume_tags                  = {}
        vpc_security_group_ids       = [
            "sg-4ee26102",
        ]

        credit_specification {
            cpu_credits = "standard"
        }

        metadata_options {
            http_endpoint               = "enabled"
            http_put_response_hop_limit = 1
            http_tokens                 = "optional"
        }

        root_block_device {
            delete_on_termination = true
            device_name           = "/dev/sda1"
            encrypted             = false
            iops                  = 100
            volume_id             = "vol-0d555eef76125a3db"
            volume_size           = 8
            volume_type           = "gp2"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Now we're back to the only change being applied being our tag change.

```
terraform apply plan.out
aws_instance.instance: Modifying... [id=i-0d02d00e96e27d752]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 10s elapsed]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 20s elapsed]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 30s elapsed]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 40s elapsed]
aws_instance.instance: Still modifying... [id=i-0d02d00e96e27d752, 50s elapsed]
aws_instance.instance: Modifications complete after 55s [id=i-0d02d00e96e27d752]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

We could yet again see the indication of a stale plan file if a similar situation happened again like tim putting in between a change before we were able to apply. The important thing here is that these mechanisms are Terraform attempting to take increased measures to keep your state and infrastructure safe, even at the cost of human interaction and workflows in certain situations.

# DESTROY

```
terraform destroy
...
```
