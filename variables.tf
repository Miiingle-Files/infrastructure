variable "alarm_sms_destination" {
  description = "Mobile number to send the Alarms via SNS"
  type        = string
  sensitive   = true
}

variable "org" {
  description = "Name of the Organization"
  type        = string
  default     = "mf"
}

variable "aws_region" {
  description = "AWS Resources created region"
  type        = string
  default     = "us-east-1"
}