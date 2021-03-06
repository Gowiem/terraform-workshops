# Exercise 9: Provisioners

We don't want to use provisioners unless we have to. And there are many cases where you're still going to be required to use them, so let's make sure we do know how to do it.

## A look at the different types of provisioners available to us via Terraform out-of-the-box

* `chef`: https://www.terraform.io/docs/provisioners/chef.html
* `file`: https://www.terraform.io/docs/provisioners/file.html
* `habitat`: https://www.terraform.io/docs/provisioners/habitat.html
* `local-exec`: https://www.terraform.io/docs/provisioners/local-exec.html
* `puppet`: https://www.terraform.io/docs/provisioners/puppet.html
* `remote-exec`: https://www.terraform.io/docs/provisioners/remote-exec.html
* `salt-masterless`: https://www.terraform.io/docs/provisioners/salt-masterless.html

What about Ansible? Well, the recommended path for running Ansible provisioning would be one of 2 different ways depending your needs or wants:

* Use `local-exec` to run `ansible-playbook` from the same machine running Terraform, remotely configuring that machine via Ansible running on your local machine
* Use `remote-exec` to install Ansible on the remote server, then run `ansible-playbook` to configure localhost

Let's look at the `local-exec` approach via an example. It'll be a good way to become familiar with provisioner configuration and patterns:

```
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "Ansible-configured Web Server"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.public_ip} ./ansible/web-server.yaml"
  }
}
```

Looking at this example, let's make sense of all the parts

The resource itself, an AWS EC2 instance. We're spinning it up in a normal Terraform way. Once the instance is up, we'll run the `provisioner` block within. In this case, it's a `local-exec` provisioner, so it's going to execute the command, `ansible-playbook -i ${self.public_ip} ./ansible/web-server.yaml` on the machine where we're executing Terraform. `${self.public_ip}` will be expanded to contain the value of the EC2 instance's public IP, and execute the `./ansible/web-server.yaml` playbook against that server remotely.

In reality, there are a few additional concerns with a provisioning setup like this:

* Can we connect to the instance from our machine, so security group/firewall concerns
* What about the SSH key for connecting, so our Ansible config to use the key and setting that as a key on the instance
* This provisioner will only run when Terraform sees this resource as changed, so when it's created, or being modified at the Terraform resource level. All other `terraform apply` runs will not execute Ansible against the instance

Let's work with an example and actually create an EC2 instance to look more closely at all of the above

## Provisioning an EC2 instance with remote-exec

We'll switch to the remote-exec provisioner type as we jump into a working example. Let's first look at our main.tf here:

```
terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 2.0"
}

provider "tls" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.student_alias}_allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "server" {
  key_name   = "${var.student_alias}-key"
  public_key = tls_private_key.server.public_key_openssh
}

resource "aws_instance" "server" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.allow_ssh.name]
  key_name        = aws_key_pair.server.key_name

  tags = {
    Name = var.student_alias
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.server.private_key_pem
    }
    source      = "./provisioner.sh"
    destination = "/tmp/provisioner.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.server.private_key_pem
    }
    inline = [
      "chmod +x /tmp/provisioner.sh",
      "/tmp/provisioner.sh"
    ]
  }
}
```

First, note that we're using a data source to query for the AMI ID to use within the region. AWS has different AMI IDs for the same machine types dependent on the region where you're creating instances. So, this data source query is a useful one when using Terraform for AWS and EC2.

A few other things to note are that we're creating a security group or firewall rule to attach to our instance. This rule says that we'll allow SSH/port 22 traffic into the instance from anywhere, and actually all traffic out as well since some of our install tasks will be installing packages to be pulled in from public locations. We also need to create a key that will be assigned to the instance, and use this key within the `provisioner` `connection` blocks. All of this being necessary for Terraform's internal provisioner process to be able to connect from the outside, and have a key for doing so. Another common pattern here would be to pass in an ssh key instead of having Terraform manage the TLS key itself.

The main thing we want to look at for this exercise is the actual AWS instance resource, and specifically the provisioner blocks.

We can have multiple provisioners in a resource.  In this case, we're including one that will first copy in our `provisioner.sh` script from our project. This file provisioner copies up that script to the `tmp` location on the EC2 instance once that instance is running and Terraform can connect to it.

Next, we have another provisioner defined that will then make that script file executable on the instance, and then finally run it.

Worth noting, that we'd probably opt for a single provisioner if we were doing this for real, something like

```
resource "aws_instance" "server" {

  ...

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.server.private_key_pem
    }
    script = "./provisioner.sh"
  }
}
```

As it would do everything we're doing with the file approach. It's helpful to see the alternatives though.

Let's see what our alternative looks like from a terraform apply perspective. First, let's initialize our project.

```
$ terraform init -backend-config=./backend.tfvars -backend-config=bucket=tf-intermediate-[student-alias]
...
```

And now we can run our apply

```
$ terraform apply
data.aws_ami.ubuntu: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.server will be created
  + resource "aws_instance" "server" {
      + ami                          = "ami-0cd230f950c3de5d8"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = "force-key"
      + network_interface_id         = (known after apply)
      + outpost_arn                  = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = [
          + "force_allow_ssh",
        ]
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name" = "force"
        }
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_key_pair.server will be created
  + resource "aws_key_pair" "server" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "force-key"
      + key_pair_id = (known after apply)
      + public_key  = (known after apply)
    }

  # aws_security_group.allow_ssh will be created
  + resource "aws_security_group" "allow_ssh" {
      + arn                    = (known after apply)
      + description            = "Allow SSH inbound traffic"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "force_allow_ssh"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = (known after apply)
    }

  # tls_private_key.server will be created
  + resource "tls_private_key" "server" {
      + algorithm                  = "RSA"
      + ecdsa_curve                = "P224"
      + id                         = (known after apply)
      + private_key_pem            = (sensitive value)
      + public_key_fingerprint_md5 = (known after apply)
      + public_key_openssh         = (known after apply)
      + public_key_pem             = (known after apply)
      + rsa_bits                   = 4096
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

tls_private_key.server: Creating...
tls_private_key.server: Creation complete after 2s [id=2601f2097b227c76df257c593f8c10c5df5417e0]
aws_key_pair.server: Creating...
aws_security_group.allow_ssh: Creating...
aws_key_pair.server: Creation complete after 1s [id=force-key]
aws_security_group.allow_ssh: Creation complete after 4s [id=sg-053e99c2649f20619]
aws_instance.server: Creating...
aws_instance.server: Still creating... [10s elapsed]
aws_instance.server: Still creating... [20s elapsed]
aws_instance.server: Provisioning with 'file'...
aws_instance.server: Still creating... [30s elapsed]
aws_instance.server: Provisioning with 'remote-exec'...
aws_instance.server (remote-exec): Connecting to remote host via SSH...
aws_instance.server (remote-exec):   Host: 54.241.239.253
aws_instance.server (remote-exec):   User: ubuntu
aws_instance.server (remote-exec):   Password: false
aws_instance.server (remote-exec):   Private key: true
aws_instance.server (remote-exec):   Certificate: false
aws_instance.server (remote-exec):   SSH Agent: true
aws_instance.server (remote-exec):   Checking Host Key: false
aws_instance.server (remote-exec): Connected!
aws_instance.server (remote-exec): Setting up our server configuration
aws_instance.server: Creation complete after 40s [id=i-0b834ef7aab941806]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

So, our instance is now created _and_ provisioned/configured. So, imagine we changed our `provisioner.sh` script and wanted to apply it. Could I simply update the script and run apply to make sure the instance is updated with the new configuration, packages, etc.? No, since Terraform won't see a change to the instance itself, it's not going to be able to re-run this provisioner. Let's see that in action.

Change your `provisioner.sh` script to be

```
#!/bin/bash

echo "Setting up our server configuration"
sudo touch /etc/config-file

echo "Setting up another configuration file"
sudo touch /etc/config-file-additional
```

and run the apply again:

```
$ terraform apply
tls_private_key.server: Refreshing state... [id=2601f2097b227c76df257c593f8c10c5df5417e0]
aws_key_pair.server: Refreshing state... [id=force-key]
data.aws_ami.ubuntu: Refreshing state...
aws_security_group.allow_ssh: Refreshing state... [id=sg-053e99c2649f20619]
aws_instance.server: Refreshing state... [id=i-0b834ef7aab941806]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

People typically solve this by decoupling the instance resource from another that contains the provisioner or provisioners: https://www.terraform.io/docs/provisioners/null_resource.html.

Looking at the example from that link, we see:

```
resource "aws_instance" "cluster" {
  count = 3

  # ...
}

resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", aws_instance.cluster.*.id)}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(aws_instance.cluster.*.public_ip, 0)}"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "bootstrap-cluster.sh ${join(" ", aws_instance.cluster.*.private_ip)}",
    ]
  }
}
```

The key here is something called a `null_resource` that also has a meta argument `triggers` defined to re-run provisioning whenever the collection of instances changes in any way. You can even go further in this type of situation and set a `triggers` property to something like `uuid()` which would be different on every run, and so Terraform will see the resource as changed and re-run the provisioners.

## DO THIS NEXT

Please run a destroy on your project to bring down the EC2 instance, security group, key pair, etc.

```
$ terraform destroy
...
```

## Alternatives to Provisioners

There are two main alternatives to provisioners that you should _seriously_ consider over provisioners if you can:

* Using cloud-init, user data as it's called in AWS to run scripts on startup
* pre-building, pre-configuring machine images so that you can just load the pre-built AMI into an AWS EC2 instance

For the first one, this is what it looks like in Terraform

```
resource "aws_instance" "nginx_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  user_data = file("user-data.sh")

  security_groups = [aws_security_group.force_nginx.name]

  tags = {
    Name = "server"
  }
}
```

So, as simple as passing in the script from our local project source. A much simpler implementation when compared to the remote-exec provisioner approach.

The second alternative is an even more powerful one to explore though. So, you might have a project that uses something like Packer to build machine images. These could be AMIs for AWS, Vagrant or Virtual Boxes for development, etc. Once these are pre-built, they become immutable or at the very least almost-complete versions of the exact servers you need to run.

Imagine the scenario of running a load-balanced, auto-scaled web server cluster. Also imagine that your scaling rules suddenly detected a ton of traffic and it realized it needed to scale up to add 2 new instances to the cluster to handle the increased traffic. In such a scenario, you want those new servers to become available SOON! If you have a bunch of provisioning and configuration tasks to do on the servers once they're up before they can be considered ready for use, this may be a massive failure in the solution. Pre-building as much as possible into a machine image could mean that you simply use that AMI. AWS needs only spin up the EC2 instance using that AMI, and few to no initialization tasks mean that server is ready nearly immediately.
