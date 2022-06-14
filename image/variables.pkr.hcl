
variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "ami_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}
