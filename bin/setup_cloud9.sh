#!/bin/bash
#
#
# Invoke this script like so to setup a Cloud9 instance for our development environment.
# curl -s https://raw.githubusercontent.com/Gowiem/terraform-workshops/master/bin/setup_cloud9.sh | bash

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
curl -O https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip
sudo unzip -o terraform_0.12.31_linux_amd64.zip -d /usr/bin/

sudo yum install -y vault

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --help

## Pull Repo
#############

mkdir -p workshop
cd workshop
git clone https://github.com/Gowiem/terraform-workshops .

## Default Our Region
######################

# Set our AWS Region for this terminal session
export AWS_DEFAULT_REGION=us-east-2
export AWS_REGION=us-east-2

# Set our AWS_DEFAULT_REGION for the future as well
echo "export AWS_DEFAULT_REGION=us-east-2" >>~/.bash_profile
echo "export AWS_REGION=us-east-2" >>~/.bash_profile

## Setup Instructor Prompt
###########################

echo 'export PS1="\[\033[01;32m\]$(_cloud9_prompt_user)\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]$(__git_ps1)\[\033[01;32m\] »\[\033[00m\] "' >>~/.bash_profile

source ~/.bash_profile
