variable "aws_region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Perfil local configurado mediante AWS CLI"
  type        = string
  default     = "iac-course"
}