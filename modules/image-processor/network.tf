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

# Subred privada ubicada en la primera zona de disponibilidad
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 11)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "image-processor-${var.environment}-private-a"
    Environment = var.environment
    Tier        = "private"
  }
}

# Subred privada ubicada en la segunda zona de disponibilidad
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 12)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "image-processor-${var.environment}-private-b"
    Environment = var.environment
    Tier        = "private"
  }
}

# Tabla de rutas para la primera subred privada
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "image-processor-${var.environment}-private-rt-a"
    Environment = var.environment
  }
}

# Tabla de rutas para la segunda subred privada
resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "image-processor-${var.environment}-private-rt-b"
    Environment = var.environment
  }
}

# Asociar la primera subred con su tabla de rutas
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

# Asociar la segunda subred con su tabla de rutas
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}
