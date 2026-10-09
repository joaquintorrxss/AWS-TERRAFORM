# Red principal para cada ambiente
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "image-processor-${var.environment}-vpc"
    Environment = var.environment
    Project     = "image-processor"
  }
}

# Obtener las zonas de disponibilidad disponibles
data "aws_availability_zones" "available" {
  state = "available"
}