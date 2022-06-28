##################################
# User input needed variables
##################################
export TF_VAR_project_name="minecraft-version2"
export TF_VAR_region="us-east-1"
export TF_VAR_availability_zone_name="us-east-1a"
export TF_VAR_instance_type="t2.medium"

export TF_VAR_backend_s3_region=$TF_VAR_region
export TF_VAR_backend_s3_key_compute="compute/terraform.tfstate"
export TF_VAR_backend_s3_key_data="data/terraform.tfstate"

export PKR_VAR_project_name=$TF_VAR_project_name
export PKR_VAR_region=$TF_VAR_region

# Optional for make cloudflare-update
# set the variables on the cloudflare-update.sh file
