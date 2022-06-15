
variable "region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sg_default_id" {
  type = string
}

variable "sg_application_id" {
  type = string
}

variable "script_path" {
  type        = string
  description = "This variable is need for runnig packer both from the root (Makefile) and data dirs."
  default     = "setup-script.sh"
}
