################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block           = "172.16.13.0/27"
  enable_dns_hostnames = true
}

################################################################################
# Public Subnet
################################################################################

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
  cidr_block              = "172.16.13.0/28"
  availability_zone       = var.availability_zone_name
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Route table association
################################################################################

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}



# Get VPC for the region
# data "aws_vpc" "selected" {
#   # default = true
#   filter {
#     name   = "tag:Project"
#     values = [var.project_name]
#   }
# }

# Fetch default SG
data "aws_security_group" "default" {
  vpc_id = aws_vpc.this.id
  name   = "default"
}

# data "aws_subnet" "this" {
#   availability_zone = var.availability_zone_name
#   vpc_id            = aws_vpc.this.id
# }

# data "aws_subnet" "selected" {
#   availability_zone = var.availability_zone_name
#   vpc_id            = aws_vpc.this.id
#   filter {
#     name   = "tag:Project"
#     values = [var.project_name]
#   }
# }

# Create Route 53 private zone minecraft.internal on default VPC
resource "aws_route53_zone" "this" {
  name = "minecraft.internal"

  vpc {
    vpc_id = aws_vpc.this.id
  }

}

# Create application SG (allow connection on ports: 22, 25565)
resource "aws_security_group" "custom" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and application port inbound traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description      = "Allow application port"
    from_port        = 25565
    to_port          = 25565
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow SSH for Packer"
    from_port        = 22
    to_port          = 22
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


# Allow EC2 instances to assume the role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

resource "aws_iam_role" "this" {
  name               = "${var.project_name}-SSMInstanceProfile"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-SSMInstanceProfile"
  role = aws_iam_role.this.name
}