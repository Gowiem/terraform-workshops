# Getting Set up for Exercises and Experiments

In this first exercise we'll make sure that we're all set up with access to AWS, and then we'll
create a Cloud9 server / dev environment where we'll run the upcoming exercises.

## Log into the AWS Console and Launch your Cloud9 Environment

1. Log in to AWS using the link, username, and password provided to you via chat or email.
1. In the top bar of the AWS Console, in the center you'll see the Services searchbar, click on it, and type "Cloud9" which will filter available services in the search list. Click on "Cloud9" which will take you to where we can create your environment.
1. **IMPORTANT**: Select **US East (Ohio) us-east-2** in the upper right corner of your AWS console as the region
1. Click on "Create Environment"
1. Give your environment a unique name (your provided student alias is suggested i.e. $FIRST_NAME-$LAST_NAME) and, optionally, a description. Click "Next"
1. Keep the settings as their defaults on this screen, then click "Next"
1. Review your settings on the next screen, and then click "Create"
1. Wait for your environment to start. In this step, AWS is provisioning an EC2 instance on which your IDE environment will run. This gives us the distinct advantage of having a consistent and controlled environment for development regardless of your hardware and OS. It also allows us to connect to our instances and AWS's API without worrying about port availability at your home or in a corporate office. 😁
1. Once your IDE loads, you should see a Welcome document. From here continue with the below steps and I'll give an intro to the Cloud9 environment once everyone has completed all the steps.

## Resize your Cloud9 disk

There really should be a way to set the root disk size to use on a Cloud9 instance, but surprisingly there isn't, so we need to increase it using some trickery at this stage:

```bash
curl -s https://gist.githubusercontent.com/wongcyrus/a4e726b961260395efa7811cab0b4516/raw/6e70a124c5cb9f6ce5519d8b5b302e8a137e5620/resize.sh | sh
```

This curl-bash pattern will execute a secript in your environment which should increase your Cloud9 root disk to 20G instead of the default 10G. You will need the extra space as `terraform init` can take up a lot of disk space.

## Setup your Environment

1. This is a fully functioning bash terminal running inside an EC2 instance, but it is the base AWS Linux 2 OS and doesn't have the things we need to execute this workshop, so lets install a couple important packages:

```bash
# Install jq - a useful tool for querying json documents from the command line.
sudo yum -y install jq

# Install Terraform - We're installing directly from Hashi, but for future usage I suggest using tfenv: https://github.com/tfutils/tfenv
curl -O https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip
sudo unzip terraform_0.12.31_linux_amd64.zip -d /usr/bin/
```

You will need to confirm the unzip command as there is a newer version of terraform installed by default in the Cloud9 environment that will need to be overwritten. You can do so by typing "A" and hitting enter.

4. Now let's confirm we terraform installed properly.

```bash
terraform -v
```

You should see something along the lines of:

```
Terraform v0.12.31

Your version of Terraform is out of date! The latest version
is 0.14.6. You can update by downloading from https://www.terraform.io/downloads.html
```

## Pull the exercises repository

The next thing we need to do is pull this repository down so we can use it in future exercises. Run the following to do this:

```bash
mkdir -p workshop
cd workshop
git clone https://github.com/Gowiem/terraform-workshops .
```

## Set a Default Region

To let our CLI and Terraform know that we want to work in the AWS us-east-2 region (Ohio), let's run the following commands:

```bash
# Set our AWS_DEFAULT_REGION for this terminal session
export AWS_DEFAULT_REGION=us-east-2
export AWS_REGION=us-east-2

# Set our AWS_DEFAULT_REGION for the future as well
echo "export AWS_DEFAULT_REGION=us-east-2" >> ~/.bash_profile
echo "export AWS_REGION=us-east-2" >> ~/.bash_profile
```

This environment variable will let Terraform (as well as other tools) know where we want to deploy things.

Having done all that, we should be ready to move on!
