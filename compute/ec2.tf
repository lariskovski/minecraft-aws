data "aws_vpc" "selected" {
  filter {
    name   = "tag:Project"
    values = [var.project_name]
  }
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Project"
    values = [var.project_name]
  }
}


data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.selected.id
  name   = "default"
}

data "aws_security_group" "custom" {
  vpc_id = data.aws_vpc.selected.id
  filter {
    name   = "tag:Project"
    values = [var.project_name]
  }
}


data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-minecraft-base*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}


resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ami.id
  associate_public_ip_address = true
  availability_zone           = var.availability_zone_name
  iam_instance_profile        = "${var.project_name}-SSMInstanceProfile"
  instance_type               = var.instance_type

  vpc_security_group_ids = [data.aws_security_group.custom.id, data.aws_security_group.default.id] # default sg for efs connection
  subnet_id              = data.aws_subnet.selected.id

  root_block_device {
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-server"
  }

}