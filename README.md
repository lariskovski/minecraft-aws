# Minecraft Server for AWS

# Requirements

- Packer

- Terraform

- jq

- AWS account


## Usage Instructions

- Export AWS credentials:

~~~~
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=ZZZZZZZZZZZZZZZZZZZZZZZZ
export AWS_DEFAULT_REGION=us-east-1
~~~~

- Deploy networking resources

- Deploy data resources 

- Build the image

- Deploy compute resources

## Packer

Packer creates a base image for our server on top of Amazon Linux AMI. It setups up anything not data related.

- Run `packer init packer/` on the firest setup or if there are changes to packer-setup-script.sh

- Format and validate the Packer template `packer fmt .` and `packer validate .`

- Build the image `packer build -var-file="build.auto.pkrvars.hcl" .`

## Terraform

- Create terraform infra including:

- Networking: SG with port 22 and 25565 + make sure to use the default sec group to EFS can access the EC2

- Data: EFS to hold world data across EC2 instances

- Compute: EC2 using Packer base image

## Sources

- New minecraft releases on https://www.minecraft.net/en-us/download/server


