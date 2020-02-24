.DEFAULT_GOAL := help
.PHONY: help tf-init tf-validate tf-plan tf-package tf-apply layer clean clean-layer cleaning artifacts

################ Project #######################
PROJECT ?= qtweet
DESCRIPTION ?= Dead simple SQS to Twitter bot
################################################

################ Config ########################
S3_BUCKET ?= ${PROJECT}-artifacts
AWS_REGION ?= eu-west-1
ENV ?= development
################################################

help:
	@echo "${PROJECT}"
	@echo "${DESCRIPTION}"
	@echo ""
	@echo "	artifacts - create required S3 bucket for artifacts storage"
	@echo "	tf-init - init Terraform IaC"
	@echo "	tf-validate - validate IaC using Terraform"
	@echo "	tf-package - prepare the package for Terraform"
	@echo "	tf-plan - plan (dryrun) IaC using Terraform"
	@echo "	tf-apply - deploy the IaC using Terraform"
	@echo "	tf-destroy - delete all previously created infrastructure using Terraform"
	@echo "	clean - clean the build folder"
	@echo "	clean-layer - clean the layer folder"
	@echo "	cleaning - clean build and layer folders"


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
tf-package: clean
	@echo "Consolidating python code in ./build"
	mkdir -p build
	make venv
	cp -R ./python/*.py ./build/

	@echo "zipping python code"
	cd build ; zip -r ../tf/function.zip *

tf-init:
	@terraform init \
		-backend-config="bucket=$(S3_BUCKET)" \
		-backend-config="key=$(PROJECT)/$(ENV)-terraform.tfstate" \
		./tf/

tf-validate:
	@terraform validate ./tf/

tf-plan:
	@terraform plan \
		-var="env=$(ENV)" \
		-var="project=$(PROJECT)" \
		-var="description=$(DESCRIPTION)" \
		-var="aws_region=$(AWS_REGION)" \
		-var="artifacts_bucket=$(S3_BUCKET)" \
		./tf/

tf-apply:
	@terraform apply \
		-var="env=$(ENV)" \
		-var="project=$(PROJECT)" \
		-var="description=$(DESCRIPTION)" \
		-compact-warnings ./tf/

tf-destroy:
	@read -p "Are you sure that you want to destroy: '$(PROJECT)-$(ENV)-$(AWS_REGION)'? [yes/N]: " sure && [ $${sure:-N} = 'yes' ]
	@terraform destroy ./tf/

################################################

################ CloudFormation ################
cfn-package: clean
	@echo "Consolidating python code in ./build"
	mkdir -p build
	cp -R ./python/*.py ./build/
	@echo "zipping python code, uploading to S3 bucket, and transforming template"
	@aws cloudformation package \
			--template-file sam.yml \
			--s3-bucket ${S3_BUCKET} \
			--output-template-file build/template-lambda.yml

	@echo "Copying updated cloud template to S3 bucket"
	aws s3 cp build/template-lambda.yml 's3://${S3_BUCKET}/template/template-lambda.yml'

cfn-deploy:
	@aws cloudformation deploy \
			--template-file build/template-lambda.yml \
			--region ${AWS_REGION} \
			--stack-name "${PROJECT}-${ENV}" \
			--parameter-overrides \
				env=${ENV} \
				project=${PROJECT} \
				description=${DESCRIPTION} \
			--capabilities CAPABILITY_IAM \
			--no-fail-on-empty-changeset

layer: clean-layer
	pip3 install \
			--isolated \
			--disable-pip-version-check \
			-Ur requirements.txt -t ./layer/
################################################

################ Cleaning ######################
clean-layer:
	@rm -fr layer/
	@rm -fr dist/
	@rm -fr htmlcov/
	@rm -fr site/
	@rm -fr .eggs/
	@rm -fr .tox/
	@find . -name '*.egg-info' -exec rm -fr {} +
	@find . -name '.DS_Store' -exec rm -fr {} +
	@find . -name '*.egg' -exec rm -f {} +
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +

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

cleaning: clean clean-layer
################################################

all: artifacts tf-package tf-init tf-validate tf-plan tf-apply
