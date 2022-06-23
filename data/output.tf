output "subnet_id" {
  value = aws_subnet.public.id
}

output "sg_default_id" {
  value = data.aws_security_group.default.id
}

output "sg_application_id" {
  value = aws_security_group.custom.id
}
