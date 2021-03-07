#!/bin/bash

## Cloud9 instance updates
###########################

# Resize our Cloud9 instances to 20GB
curl -s \
    https://gist.githubusercontent.com/wongcyrus/a4e726b961260395efa7811cab0b4516/raw/6e70a124c5cb9f6ce5519d8b5b302e8a137e5620/resize.sh |
    sh

## Install our tools
#####################

# Install jq - a useful tool for querying json documents from the command line.
sudo yum -y install jq

# Install Terraform - We're installing directly from Hashi, but for future usage I suggest using tfenv: https://github.com/tfutils/tfenv
curl -O https://releases.hashicorp.com/terraform/0.12.30/terraform_0.12.30_linux_amd64.zip
sudo unzip -o terraform_0.12.30_linux_amd64.zip -d /usr/bin/;

## Pull Repo
#############

mkdir -p workshop
cd workshop
git clone https://github.com/Gowiem/terraform-workshops .

## Default Our Region
######################

# Set our AWS_DEFAULT_REGION for this terminal session
export AWS_DEFAULT_REGION=us-east-2

# Set our AWS_DEFAULT_REGION for the future as well
echo "export AWS_DEFAULT_REGION=us-east-2" >>~/.bash_profile
