# Getting Set up for Exercises and Experiments

In this first exercise we'll just make sure that you're all set up with your AWS credentials, access to AWS, and get
a Cloud9 server/environment set up where you'll run further exercises.

## Log into the AWS Console and Create an Access Key for yourself

1. Log in to AWS using the link, username, and password provided to you
1. In the top bar, near the right, you'll see your username/alias @ rockholla-di. Click on it which will show a dropdown
1. In the dropdown, click on "My Security Credentials"
1. This will take you to your security credentials screen/tab. Feel free to change your password if you like, you'll be using this account for the next few days.
1. Click "Create access key"
1. An access key and secret will be created for you, **copy the Access key ID and Secret access key, we'll use them in setting your environment up below**
1. Close out of the modal/pop-up

## Launch your Environment

1. In the top bar of the AWS Console, near the left, you'll see "Services", click on it, and in the drop down search box, type "Cloud9" which will filter available services in the search list. Click on "Cloud9" which will take you to where we can create your environment.
1. **IMPORTANT**: Select **US West (N. California) us-west-1** in the upper right corner of your AWS console as the region
1. Click on "Create Environment"
1. Give your environment a unique name (your student alias is suggested) and, optionally, a description. Click "Next Step"
1. Keep the settings as their defaults on this screen, then click "Next Step"
1. Review your settings on the next screen, and then click "Create Environment"
1. Wait for your environment to start.  In this step, AWS is provisioning an EC2 instance that your IDE environment will run on.  This gives us the distinct advantage of having a controlled environment for development regardless of client hardware and OS.  In the case of this workshop, it also allows us to connect to our instances and AWS's API without worrying about port availability in a corporate office. :-)
1. Once your IDE loads, you should see a Welcome document.  Your instructor will give you a walkthrough of the visible panel.  Feel free to take a moment to read through the welcome document.

## Resize your Cloud9 disk

There really should be a way to set the root disk size to use on a Cloud9 instance, but surprisingly there isn't, so we need to increase it using some trickery at this stage:

```bash
curl -s https://gist.githubusercontent.com/wongcyrus/a4e726b961260395efa7811cab0b4516/raw/543fe335adaf7222f5f4fca475cf716d61b9a77b/resize.sh | sh
```

This should increase and grow your Cloud9 root disk to 20G

## Configure your environment

1. Below the Welcome Document, you should see a terminal panel.
1. Feel free to resize the terminal panel to your liking.
1. This is a fully functioning bash terminal running inside an EC2 instance, but it is the base AWS Linux OS and doesn't have the things we need to execute this workshop, so lets install a few packages.

```bash
sudo yum -y install jq git
sudo pip install --upgrade pip
sudo ln -s /usr/local/bin/pip /bin/pip
# you can ignore errors running this last command
sudo pip install --upgrade awscli
```

## Install Terraform

Run these commands in your cloud9 IDE terminal window to install Terraform

```bash
curl -O https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip
sudo unzip terraform_0.12.29_linux_amd64.zip -d /usr/bin/
```

Then test to ensure it was installed properly.

```bash
terraform -v
```

If you get an error, inform your instructor.

## Install Packer (only for those taking the Introduction to Terraform and Packer course)

Similarly, you'll want to install the Packer CLI as well

```bash
curl -O https://releases.hashicorp.com/packer/1.5.6/packer_1.5.6_linux_amd64.zip
sudo unzip packer_1.5.6_linux_amd64.zip -d /usr/bin/
```

And test to make sure this installed properly as well

```bash
packer -v
```

If you get an error, inform your instructor.

## Pull the exercises repository

The next thing we need to do is pull this repository down so we can use it in future modules.  Run the following to
do this:

```bash
git clone https://github.com/rockholla/terraform-packer-workshop workshop
```

## Set up your environment credentials to connect to AWS

place the following in your `$HOME/.bash_profile` file at the bottom, and replace the values in brackets with your generated creds:
```
export AWS_ACCESS_KEY_ID=[The access key ID you created above]
export AWS_SECRET_ACCESS_KEY=[The secret access key you created above]
export AWS_DEFAULT_REGION=us-west-1
```

Then source your new .bash_profile and ensure environment has the appropriate env vars set:
```
. $HOME/.bash_profile
printenv | grep AWS
```

The printenv above should output something like:
```
AWS_DEFAULT_REGION=us-west-1
AWS_SECRET_ACCESS_KEY=********
AWS_CLOUDWATCH_HOME=/opt/aws/apitools/mon
AWS_ACCESS_KEY_ID=********
AWS_PATH=/opt/aws
AWS_AUTO_SCALING_HOME=/opt/aws/apitools/as
AWS_ELB_HOME=/opt/aws/apitools/elb
```

Having done that, we should be ready to move on!
