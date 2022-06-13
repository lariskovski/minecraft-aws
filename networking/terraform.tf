
# Fetch default SG
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}


# Get default VPC for the region
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "this" {
  availability_zone = var.availability_zone_name
  vpc_id            = data.aws_vpc.default.id
}

# Create Route 53 private zone minecraft.internal on default VPC
resource "aws_route53_zone" "this" {
  name = "minecraft.internal"

  vpc {
    vpc_id = data.aws_vpc.default.id
  }

}

# Create application SG (allow connection on ports: 22, 25565)
resource "aws_security_group" "custom" {
  name        = var.project_name
  description = "Allow application port inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "Allow application port"
    from_port        = 25565
    to_port          = 25565
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
