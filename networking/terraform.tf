
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

# Create the policy which allows other actions for the EC2 instance
data "aws_iam_policy_document" "ssm_policy" {
  statement {
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "this" {
  name = "SSMInstanceProfile"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  
  # Attach the policy
  inline_policy {
    policy = data.aws_iam_policy_document.ssm_policy.json
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "this" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.this.name
}
