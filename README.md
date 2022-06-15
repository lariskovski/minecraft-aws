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
~~~~

- Edit env.sh accordingly

- Deploy data resources: `make data-plan` and `make data-apply` 

- Build the image: `make packer-build`

- Deploy compute resources:  `make compute-plan` and `make compute-apply`

- Optionally edit the cloudflare-update.sh file environments. The script is used in a target to automatically update a Cloudflare dns record with the new EC2's public IP. `make cloudflare-update`

## What does Packer do?

Packer creates a base image for our server on top of Amazon Linux AMI 2. It setups up anything not data-related.

- Run `packer init` on the firest setup or if there are changes to packer-setup-script.sh

- Format and validate the Packer template `packer fmt .` and `packer validate .`

- Build the image `packer build .`

## What about Terraform?

- Creates the infra including:

    - Networking: SG with port 22 and 25565 + make sure to use the default sec group to EFS can access the EC2

    - Data: EFS to hold data across EC2 instances + EFS DNS entry on Route 53

    - Compute: EC2 using Packer base image

## Sources

- New minecraft releases on https://www.minecraft.net/en-us/download/server


