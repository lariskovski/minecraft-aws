# Each target runs on a single shell as opposed to every line running its own
.ONESHELL:

# There is no source on sh
SHELL := /bin/bash
DATA_DIR := data
COMPUTE_DIR := compute
IMAGE_DIR := image

ifndef AWS_ACCESS_KEY_ID
$(error AWS_ACCESS_KEY_ID is not set. Please set it before trying again.)
endif


tf-init:
	terraform -chdir=$(DATA_DIR) init

# DATA RESOUCES
data-validate: tf-init
	terraform -chdir=$(DATA_DIR) fmt .
	terraform -chdir=$(DATA_DIR) validate .

data-plan: data-validate
	source env.sh
	terraform -chdir=$(DATA_DIR) plan -out plan

data-apply: data-plan
	# env | grep -i tf
	# echo "terraform -chdir=$(DATA_DIR) apply plan"
	terraform -chdir=$(DATA_DIR) apply plan


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
compute-validate:
	terraform -chdir=$(COMPUTE_DIR) fmt .
	terraform -chdir=$(COMPUTE_DIR) validate .

compute-plan: compute-validate
	source env.sh
	terraform -chdir=$(DATA_DIR) output -json | jq -r '@sh "\nexport TF_VAR_sg_default_id=\(.sg_default_id.value)\nexport TF_VAR_subnet_id=\(.subnet_id.value)\nexport TF_VAR_sg_application_id=\(.sg_application_id.value)\nexport PKR_VAR_sg_default_id=\(.sg_default_id.value)\nexport PKR_VAR_subnet_id=\(.subnet_id.value)\nexport PKR_VAR_sg_application_id=\(.sg_application_id.value)"' >> temp-env.sh
	source temp-env.sh && rm -f temp-env.sh
	terraform -chdir=$(COMPUTE_DIR) plan -out plan

compute-apply: compute-plan
	# echo "terraform -chdir=$(COMPUTE_DIR) apply plan"
	terraform -chdir=$(COMPUTE_DIR) apply plan

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
