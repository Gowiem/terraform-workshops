# Getting Set up for Exercises and Experiments

In this first exercise we'll make sure that we're all set up with our AWS credentials and access to AWS, and then we'll
create a Cloud9 server/environment where we'll run further exercises.

## Log into the AWS Console and Launch your Cloud9 Environment

1. Log in to AWS using the link, username, and password provided to you via email
1. In the top bar of the AWS Console, in the center you'll see the Services searchbar, click on it, and type "Cloud9" which will filter available services in the search list. Click on "Cloud9" which will take you to where we can create your environment.
1. **IMPORTANT**: Select **US East (Ohio) us-east-2** in the upper right corner of your AWS console as the region
1. Click on "Create Environment"
1. Give your environment a unique name (your full name with no spaces is suggested) and, optionally, a description. Click "Next"
1. Keep the settings as their defaults on this screen, then click "Next"
1. Review your settings on the next screen, and then click "Create"
1. Wait for your environment to start. In this step, AWS is provisioning an EC2 instance on which your IDE environment will run. This gives us the distinct advantage of having a consistent and concontrolled environment for development regardless of client hardware and OS. It also allows us to connect to our instances and AWS's API without worrying about port availability in a corporate office. 😁
1. Once your IDE loads, you should see a Welcome document. You can stop here for a minute as I will give you a quick walkthrough of the environment. Feel free to take the time to read through the welcome document.


## Setup your Environment

1. Below the Welcome Document, you should see a terminal panel.
1. Feel free to resize the terminal panel to your liking.
1. This is a fully functioning bash terminal running inside an EC2 instance, but it is the base AWS Linux OS and doesn't have the things we need to execute this workshop, so lets install a couple important packages:

```bash
# Install jq - a useful tool for querying json documents from the command line.
sudo yum -y install jq

# Install Terraform - We're installing directly from Hashi, but for future usage I suggest using tfenv: https://github.com/tfutils/tfenv
curl -O https://releases.hashicorp.com/terraform/0.12.30/terraform_0.12.30_linux_amd64.zip
sudo unzip terraform_0.12.30_linux_amd64.zip -d /usr/bin/
```

4. Now let's confirm we terraform installed properly.

```bash
terraform -v
```

## Pull the exercises repository

The next thing we need to do is pull this repository down so we can use it in future modules. Run the following to do this:

```bash
mkdir -p workshop
cd workshop
git clone https://github.com/Gowiem/terraform-workshop .
```

## Confirm your AWS access

Before we move on, let's make sure we have our AWS credentials setup correctly. To do this, we need to confirm that our Cloud9 Environment was properly setup with an access key pair and defaults to our selected region (Ohio). To do that, run the following command:

```bash
env | grep AWS
```

The printenv above should output something like:
```
AWS_SECRET_ACCESS_KEY=xxxxxxx
AWS_DEFAULT_REGION=us-east-2
AWS_CLOUDWATCH_HOME=/opt/aws/apitools/mon
AWS_ACCESS_KEY_ID=xxxxxx
AWS_PATH=/opt/aws
AWS_AUTO_SCALING_HOME=/opt/aws/apitools/as
AWS_ELB_HOME=/opt/aws/apitools/elb
```

Having done that, we should be ready to move on!
