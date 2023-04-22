.DEFAULT_GOAL := help
.PHONY: help tf-init tf-validate tf-plan package tf-apply clean artifacts

################ Project #######################
PROJECT ?= qtweet
DESCRIPTION ?= Dead simple SQS to Twitter bot
################################################

################ Config ########################
S3_BUCKET ?= ${PROJECT}-artifacts
AWS_REGION ?= eu-west-1
ENV ?= mamip
################################################

help:
	@echo "${PROJECT}"
	@echo "${DESCRIPTION}"
	@echo ""
	@echo "	artifacts - create required S3 bucket for artifacts storage"
	@echo "	tf-init - init Terraform IaC"
	@echo "	tf-validate - validate IaC using Terraform"
	@echo "	package - prepare the package for Terraform"
	@echo "	tf-plan - plan (dryrun) IaC using Terraform"
	@echo "	tf-apply - deploy the IaC using Terraform"
	@echo "	tf-destroy - delete all previously created infrastructure using Terraform"
	@echo "	clean - clean the build folder"


################ Artifacts #####################
artifacts:
	@echo "Creation of artifacts bucket"
	@aws s3 mb s3://$(S3_BUCKET)
	@aws s3api put-bucket-encryption --bucket $(S3_BUCKET) \
		--server-side-encryption-configuration \
		'{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
	@aws s3api put-bucket-versioning --bucket $(S3_BUCKET) --versioning-configuration Status=Enabled
################################################

################### venv #######################
venv: clean-venv
	cd python && \
	python3 -m venv venv && \
	source ./venv/bin/activate && \
	pip3 install --disable-pip-version-check -r ./requirements.txt -t ../build/
################################################

################ Terraform #####################
package: clean
	@echo "Consolidating python code in ./build"
	mkdir -p build
	make venv
	cp -R ./python/*.py ./build/

	@echo "zipping python code"
	cd build ; zip -r ../tf/function.zip *

tf-init:
	@terraform -chdir=tf/ init \
		-backend-config="bucket=$(S3_BUCKET)" \
		-backend-config="key=$(PROJECT)/$(ENV)-terraform.tfstate"

tf-validate:
	@terraform -chdir=tf/ fmt
	@terraform -chdir=tf/ validate

tf-plan: tf-validate
	@terraform -chdir=tf/ plan \
		-var="env=$(ENV)" \
		-var="project=$(PROJECT)" \
		-var="description=$(DESCRIPTION)" \
		-var="aws_region=$(AWS_REGION)" \
		-var="artifacts_bucket=$(S3_BUCKET)"

tf-apply: package
	@terraform -chdir=tf/ apply \
		-var="env=$(ENV)" \
		-var="project=$(PROJECT)" \
		-var="description=$(DESCRIPTION)" \
		-compact-warnings

tf-destroy:
	@read -p "Are you sure that you want to destroy: '$(PROJECT)-$(ENV)-$(AWS_REGION)'? [yes/N]: " sure && [ $${sure:-N} = 'yes' ]
	@terraform -chdir=tf/ destroy

################################################

################ Cleaning ######################

clean-venv: clean
	rm -rf ./python/venv

clean:
	@rm -fr build/
	@rm -fr dist/
	@rm -fr htmlcov/
	@rm -fr site/
	@rm -fr .eggs/
	@rm -fr .tox/
	@rm -fr *.tfstate
	@rm -fr *.tfplan
	@rm -fr function.zip
	@rm -fr .tf/function.zip
	@find . -name '*.egg-info' -exec rm -fr {} +
	@find . -name '.DS_Store' -exec rm -fr {} +
	@find . -name '*.egg' -exec rm -f {} +
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +
################################################

all: artifacts package tf-init tf-validate tf-plan tf-apply
