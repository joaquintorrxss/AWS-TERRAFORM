output "environment" {
  description = "Entorno configurado"
  value       = var.environment
}

output "vpc_cidr" {
  description = "CIDR asignado al entorno"
  value       = var.vpc_cidr
}

# Identificador de la VPC
output "vpc_id" {
  description = "ID de la VPC del entorno"
  value       = aws_vpc.main.id
}

# Subredes privadas para las funciones Lambda
output "private_subnet_ids" {
  description = "Subredes privadas utilizadas por las Lambdas"

  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

# Security Group para las funciones Lambda
output "lambda_security_group_id" {
  description = "ID del Security Group de Lambda"
  value       = aws_security_group.lambda.id
}

# Identificador del endpoint de S3
output "s3_endpoint_id" {
  description = "ID del Gateway Endpoint de S3"
  value       = aws_vpc_endpoint.s3.id
}
