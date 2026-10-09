# ============================================================
# ALMACENAMIENTO S3
# ============================================================

# Se utiliza el ID de la cuenta para generar un nombre de bucket
# globalmente unico.
data "aws_caller_identity" "current" {}

locals {
  bucket_name      = "image-processor-${var.environment}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  uploads_prefix   = "uploads/"
  processed_prefix = "processed/"
}

resource "aws_s3_bucket" "images" {
  bucket = local.bucket_name

  # Se habilita para facilitar terraform destroy durante la actividad.
  # Permite eliminar el bucket incluso si contiene objetos de prueba.
  force_destroy = true

  tags = {
    Name        = "image-processor-${var.environment}"
    Environment = var.environment
    Project     = "image-processor"
  }
}

# Bloquea cualquier exposicion publica del bucket.
resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cifrado administrado por Amazon S3.
resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
