
variable "region" {
  type = string
}

variable "project" {
  type = string
}


variable "ami_name" {
  type = string
}

variable "vpc_id" {
  type = string
}


variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}


packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "this" {
  ami_name      = var.ami_name
  region        = var.region
  instance_type = "t2.micro"

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  security_group_ids = var.security_group_ids # needs default SG for efs connection + another SG for SSH

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
  name    = var.project
  sources = ["source.amazon-ebs.this"]

  provisioner "shell" {
    script = "setup-script.sh"

    pause_before = "10s"
    timeout      = "10s"
  }
}
