packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "this" {
  ami_name      = "amzn2-ami-minecraft-base"
  region        = var.region
  instance_type = "t2.micro"

  subnet_id = var.subnet_id

  security_group_ids = [var.sg_application_id, var.sg_default_id] # needs default SG for efs connection + another SG for SSH

  # Amazon Linux 2
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-kernel-5.10-hvm-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }
  ssh_username = "ec2-user"
}

build {
  name    = var.project_name
  sources = ["source.amazon-ebs.this"]

  provisioner "shell" {
    script = "setup-script.sh"

    pause_before = "10s"
    timeout      = "10s"
  }
}
