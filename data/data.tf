
resource "aws_efs_file_system" "efs-minecraft" {
  availability_zone_name = var.availability_zone_name

  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS"
  }
}

resource "aws_efs_mount_target" "this" {
  file_system_id = aws_efs_file_system.efs-minecraft.id
  subnet_id      = aws_subnet.public.id
}

data "aws_route53_zone" "selected" {
  name         = "minecraft.internal"
  private_zone = true
  tags = {
    Project = var.project_name
  }
}

resource "aws_route53_record" "this" {
  zone_id         = data.aws_route53_zone.selected.id
  allow_overwrite = true
  name            = "efs.minecraft.internal"
  type            = "CNAME"
  ttl             = "300"
  records         = [aws_efs_file_system.efs-minecraft.dns_name]
  depends_on      = [aws_efs_file_system.efs-minecraft]
}
