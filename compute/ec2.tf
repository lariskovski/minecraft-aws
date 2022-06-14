
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
  iam_instance_profile        = "SSMInstanceProfile" # !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  instance_type               = var.instance_type

  vpc_security_group_ids = [var.sg_application_id, var.sg_default_id] # default sg for efs connection
  subnet_id              = var.subnet_id

  root_block_device {
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-server"
  }

}