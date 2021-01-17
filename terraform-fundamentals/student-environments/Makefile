SHELL := /bin/bash

PGP_KEY_NAME ?= "Matt Gowie"

tf/init:
	terraform init

tf/plan: tf/init
	@export TF_VAR_pgp_key=$(gpg --export "$(PGP_KEY_NAME)" | base64) && \
		terraform plan -out=run.plan