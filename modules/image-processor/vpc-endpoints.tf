# Endpoint privado para acceder a Amazon S3 desde la VPC
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id
  ]

  tags = {
    Name        = "image-processor-${var.environment}-s3-endpoint"
    Environment = var.environment
  }
}