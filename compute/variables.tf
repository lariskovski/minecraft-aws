variable "region" {
  type = string
}

variable "availability_zone_name" {
  type = string
}

variable "GITHUB_USER" {
  type      = string
  sensitive = true
}

variable "GITHUB_REPO" {
  type      = string
  sensitive = true
}

variable "GITHUB_AUTH_TOKEN" {
  type      = string
  sensitive = true
}

variable "project_name" {
  type = string
}

variable "instance_type" {
  type = string
}
