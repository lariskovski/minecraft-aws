variable "region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zone_name" {
  type    = string
  default = "us-east-1c"
}

variable "sg_default_id" {
  type    = string
  default = "sg-26220c60"
}

variable "sg_application_id" {
  type    = string
  default = "sg-0b40168cbaf1ea25c"
}

variable "subnet_id" {
  type    = string
  default = "subnet-c443498e"
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "project_name" {
  type    = string
  default = "minecraft"
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}
