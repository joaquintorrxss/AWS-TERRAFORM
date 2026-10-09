variable "environment" {
  description = "Entorno donde se desplegara la infraestructura"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "El entorno debe ser dev, qa o prod."
  }
}

variable "aws_region" {
  description = "Region de AWS utilizada por la infraestructura"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloque CIDR asignado a la VPC del entorno"
  type        = string
}
