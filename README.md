# Minecraft Server for AWS

# Requirements

- Packer

- Terraform

- jq

- AWS account


## Usage Instructions

- Export AWS credentials and bucket for tfstate:

~~~~
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=ZZZZZZZZZZZZZZZZZZZZZZZZ
export TF_VAR_backend_s3_bucket="tfstates-bucket"
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

Creates the infra including:

- Networking: SG with port 22 and 25565 + make sure to use the default sec group to EFS can access the EC2

- Data: EFS to hold data across EC2 instances + EFS DNS entry on Route 53

- Compute: EC2 using Packer base image

## Cloudflare

Optionally update Cloudflare DNS entry with new instance's public IP exporting the env vars bellow then running `make cloudflare-update`

~~~~
export CLOUDFLARE_TOKEN=xxxxxxxxxxxxxxxxxx
export ZONE_ID=zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
export RECORD=minecraft.yourdomain.com
~~~~

## Auto Destroy

Python script checks via rcon for online players. If its 0 for more than 15 minutes, script calls Github API to trigger the destroy workflow.

### Setup

[Repository dispatch documentation](https://docs.github.com/en/rest/repos/repos#create-a-repository-dispatch-event)

Create a personal Github [token](https://github.com/settings/tokens)

> Make sure you add repo and workflow permissions

The API call:

~~~~
USERNAME=lariskovski
REPO=minecraft-aws
TOKEN=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
curl --request POST \
  --url 'https://api.github.com/repos/lariskovski/minecraft-aws/dispatches' \
  --header 'authorization: Bearer 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' \
  --data '{"event_type": "destroy"}'
~~~~

## Sources

- New minecraft releases on https://www.minecraft.net/en-us/download/server


