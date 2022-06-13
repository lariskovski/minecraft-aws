output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_id" {
  value = data.aws_subnet.this.id
}

output "sg_default_id" {
  value = data.aws_security_group.default.id
}

output "sg_application_id" {
  value = aws_security_group.custom.id
}

output "route53_zone_id" {
  value = aws_route53_zone.this.id
}