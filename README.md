# Minecraft Server for AWS

<img src="https://pa1.narvii.com/6035/d4c70239439859292ff9ab0eb0d7ad0e1c4a4faa_hq.gif" alt="drawing" width="200" height="200"/>

Very cool Minecraft server infrastructure setup for AWS. Created for fun and to practice some skills. Making use of EC2, EFS, S3, Route 53, IAM and other AWS services. Terraform and Packer tools (also Cloudflare).

## Getting Started

### Dependencies

- [Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)

- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

- [Active AWS account](https://aws.amazon.com/pt/console/)


### Github Actions Secrets

The following secrets need to be set so the workflows work as expected.

| Secret                   | Example                                  | Description                                                                                                                                     |
|--------------------------|------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| AWS_ACCESS_KEY_ID        | AKIAIOSFODNN7EXAMPLE                     | [Setting Up Credentials](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)                                    |
| AWS_SECRET_ACCESS_KEY    | wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY | [Setting Up Credentials](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)                                    |
| TF_VAR_BACKEND_S3_BUCKET | my-unique-bucket                         | Bucket name for storing TFstate                                                                                                                 |
| CLOUDFLARE_TOKEN         | uyvUrefBhbuQNsjZJUBZsuBypdnbZVghgEXAMPLE | [Cloudflare API token](https://developers.cloudflare.com/api/tokens/create/)                                                                    |
| ZONE_ID                  | rnc95m5rsvsvw8z9mm7xx282gEXAMPLE         | Cloudflare Zone ID where the record is being updated/created.[Get the Zone ID](https://community.cloudflare.com/t/where-to-find-zone-id/132913) |
| RECORD                   | minecraft.mydomain.com                   | Record being updated to the EC2 instance's Public IP                                                                                            |

### Executing Locally

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

### Packer, Terraform and Cloudflare

#### What does Packer do?

Packer creates a base image for our server on top of Amazon Linux AMI 2. It setups up anything not data-related.

- Run `packer init` on the firest setup or if there are changes to packer-setup-script.sh

- Format and validate the Packer template `packer fmt .` and `packer validate .`

- Build the image `packer build .`

#### What about Terraform?

Creates the infra including:

- Networking: SG with port 22 and 25565 + make sure to use the default sec group to EFS can access the EC2

- Data: EFS to hold data across EC2 instances + EFS DNS entry on Route 53

- Compute: EC2 using Packer base image

### Cloudflare

Optionally update Cloudflare DNS entry with new instance's public IP exporting the env vars bellow then running `make cloudflare-update`

~~~~
export CLOUDFLARE_TOKEN=xxxxxxxxxxxxxxxxxx
export ZONE_ID=zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
export RECORD=minecraft.yourdomain.com
~~~~

### Destroy Monitor

Python script checks via rcon for online players. If its 0 for more than 20 minutes, script calls Github API to trigger the destroy workflow.

[Repository dispatch documentation](https://docs.github.com/en/rest/repos/repos#create-a-repository-dispatch-event)

Create a personal Github [token](https://github.com/settings/tokens)

> Make sure you add repo and workflow permissions

## Resources

[New minecraft releases](https://www.minecraft.net/en-us/download/server)

[Github and Makefiles](https://www.freecodecamp.org/news/a-lightweight-tool-agnostic-ci-cd-flow-with-github-actions/)

[Manually Run Github Action](https://christinavhastenrath.medium.com/how-to-run-github-actions-manually-afebbe77d325)

[Github Doc](https://docs.github.com/en/rest/actions)


