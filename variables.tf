# pro tip: set this using the env (export TF_VAR_admin_mobile_number=6391xxxxxxx)
variable "admin_mobile_number" {
  description = "Mobile number to send the Alarms via SNS"
  type        = string
  sensitive   = true
}

variable "org" {
  description = "Name of the Organization"
  type        = string
  default     = "mf"
}

variable "reverse_domain" {
  default = "net.miiingle.files"
}

variable "aws_region" {
  description = "AWS Resources created region"
  type        = string
  default     = "us-east-1"
}