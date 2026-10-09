# Grupo de seguridad para las funciones Lambda
resource "aws_security_group" "lambda" {
  name        = "image-processor-${var.environment}-lambda-sg"
  description = "Grupo de seguridad para las funciones Lambda"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "image-processor-${var.environment}-lambda-sg"
    Environment = var.environment
  }
}

# Permitir conexiones HTTPS hacia Amazon S3
resource "aws_vpc_security_group_egress_rule" "lambda_s3" {
  security_group_id = aws_security_group.lambda.id

  description = "Permitir HTTPS hacia Amazon S3"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  prefix_list_id = data.aws_prefix_list.s3.id
}

# Obtener el identificador de red regional de Amazon S3
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}
