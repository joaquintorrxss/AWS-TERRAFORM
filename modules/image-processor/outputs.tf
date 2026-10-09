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

output "bucket_name" {
  description = "Nombre del bucket utilizado para almacenar imagenes"
  value       = aws_s3_bucket.images.id
}

output "uploads_prefix" {
  description = "Prefijo utilizado para las imagenes originales"
  value       = local.uploads_prefix
}

output "processed_prefix" {
  description = "Prefijo utilizado para las imagenes procesadas"
  value       = local.processed_prefix
}

output "image_processing_queue_url" {
  description = "URL de la cola principal de procesamiento"
  value       = aws_sqs_queue.image_processing.id
}

output "image_processing_queue_arn" {
  description = "ARN de la cola principal de procesamiento"
  value       = aws_sqs_queue.image_processing.arn
}

output "image_processing_dlq_url" {
  description = "URL de la Dead Letter Queue"
  value       = aws_sqs_queue.image_processing_dlq.id
}
