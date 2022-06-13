
resource "aws_efs_file_system" "efs-minecraft" {
  availability_zone_name = var.availability_zone_name

  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS"
  }

}

resource "aws_route53_record" "this" {
  zone_id         = var.route53_zone_id
  allow_overwrite = true
  name            = "efs.minecraft.internal"
  type            = "CNAME"
  ttl             = "300"
  records         = [aws_efs_file_system.efs-minecraft.dns_name]
  depends_on      = [aws_efs_file_system.efs-minecraft]
}
