# Each target runs on a single shell as opposed to every line running its own
.ONESHELL:

# Change shell to bash as there is no source command on sh
SHELL := /bin/bash
DATA_DIR := data
COMPUTE_DIR := compute
IMAGE_DIR := image

TF_VAR_project_name:=minecraft
TF_VAR_region:=us-east-1
TF_VAR_availability_zone_name:=us-east-1c
TF_VAR_instance_type:=t2.small
TF_VAR_backend_s3_region:=$(TF_VAR_region)
TF_VAR_backend_s3_key_compute:=compute/terraform.tfstate
TF_VAR_backend_s3_key_data:=data/terraform.tfstate
PKR_VAR_project_name:=$(TF_VAR_project_name)
PKR_VAR_region:=$(TF_VAR_region)

ifndef AWS_ACCESS_KEY_ID
$(error AWS_ACCESS_KEY_ID is not set. Please set it before trying again.)
endif


# DATA RESOUCES
data-init:
	source env.sh
	terraform -chdir=$(DATA_DIR) init -backend-config "bucket=$(TF_VAR_backend_s3_bucket)" -backend-config "region=$(TF_VAR_backend_s3_region)"  -backend-config "key=$(TF_VAR_project_name)/$(TF_VAR_backend_s3_key_data)"

data-validate:
	terraform -chdir=$(DATA_DIR) fmt .
	terraform -chdir=$(DATA_DIR) validate .

data-plan: data-validate
	source env.sh
	terraform -chdir=$(DATA_DIR) plan -out plan

data-apply:
	terraform -chdir=$(DATA_DIR) apply plan
	rm -rf $(DATA_DIR)/plan


# PACKER TEMPLATE
packer-init:
	packer init $(IMAGE_DIR)

packer-validate:
	source env.sh
	terraform -chdir=$(DATA_DIR) output -json | jq -r '@sh "\nexport TF_VAR_sg_default_id=\(.sg_default_id.value)\nexport TF_VAR_subnet_id=\(.subnet_id.value)\nexport TF_VAR_sg_application_id=\(.sg_application_id.value)\nexport PKR_VAR_sg_default_id=\(.sg_default_id.value)\nexport PKR_VAR_subnet_id=\(.subnet_id.value)\nexport PKR_VAR_sg_application_id=\(.sg_application_id.value)"' >> temp-env.sh
	source temp-env.sh
	rm -f temp-env.sh
	packer fmt $(IMAGE_DIR)
	packer validate -var "script_path=$(IMAGE_DIR)/setup-script.sh" $(IMAGE_DIR)

packer-build: packer-validate
	source env.sh
	terraform -chdir=$(DATA_DIR) output -json | jq -r '@sh "\nexport TF_VAR_sg_default_id=\(.sg_default_id.value)\nexport TF_VAR_subnet_id=\(.subnet_id.value)\nexport TF_VAR_sg_application_id=\(.sg_application_id.value)\nexport PKR_VAR_sg_default_id=\(.sg_default_id.value)\nexport PKR_VAR_subnet_id=\(.subnet_id.value)\nexport PKR_VAR_sg_application_id=\(.sg_application_id.value)"' >> temp-env.sh
	source temp-env.sh && rm -f temp-env.sh
	# echo "packer build -var "script_path=$(IMAGE_DIR)/setup-script.sh" $(IMAGE_DIR)"
	packer build -var "script_path=$(IMAGE_DIR)/setup-script.sh" $(IMAGE_DIR)


# COMPUTE RESOURCES
compute-init:
	terraform -chdir=$(COMPUTE_DIR) init -backend-config "bucket=$(TF_VAR_backend_s3_bucket)" -backend-config "region=$(TF_VAR_backend_s3_region)"  -backend-config "key=$(TF_VAR_project_name)/$(TF_VAR_backend_s3_key_compute)"

compute-validate:
	terraform -chdir=$(COMPUTE_DIR) fmt .
	terraform -chdir=$(COMPUTE_DIR) validate .

compute-plan: compute-validate
	terraform -chdir=$(DATA_DIR) output -json | jq -r '@sh "\nexport TF_VAR_sg_default_id=\(.sg_default_id.value)\nexport TF_VAR_subnet_id=\(.subnet_id.value)\nexport TF_VAR_sg_application_id=\(.sg_application_id.value)\nexport PKR_VAR_sg_default_id=\(.sg_default_id.value)\nexport PKR_VAR_subnet_id=\(.subnet_id.value)\nexport PKR_VAR_sg_application_id=\(.sg_application_id.value)"' >> temp-env.sh
	source temp-env.sh && rm -f temp-env.sh
	terraform -chdir=$(COMPUTE_DIR) plan -out plan

compute-apply:
	terraform -chdir=$(COMPUTE_DIR) apply plan
	rm -rf $(COMPUTE_DIR)/plan

compute-destroy:
	source env.sh
	terraform -chdir=$(DATA_DIR) output -json | jq -r '@sh "\nexport TF_VAR_sg_default_id=\(.sg_default_id.value)\nexport TF_VAR_subnet_id=\(.subnet_id.value)\nexport TF_VAR_sg_application_id=\(.sg_application_id.value)\nexport PKR_VAR_sg_default_id=\(.sg_default_id.value)\nexport PKR_VAR_subnet_id=\(.subnet_id.value)\nexport PKR_VAR_sg_application_id=\(.sg_application_id.value)"' >> temp-env.sh
	source temp-env.sh && rm -f temp-env.sh
	# echo "terraform -chdir=$(COMPUTE_DIR) destroy"
	terraform -chdir=$(COMPUTE_DIR) destroy


cloudflare-update:
	terraform -chdir=$(COMPUTE_DIR) output -json | jq -r '"\nexport AWS_INSTANCE_PUBLIC_IP=\(.instance_public_ip.value)"' >> temp-env.sh
	source temp-env.sh && rm -f temp-env.sh
	chmod +x cloudflare-update.sh && ./cloudflare-update.sh
