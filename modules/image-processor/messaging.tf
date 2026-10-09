# ============================================================
# DEAD LETTER QUEUE
# ============================================================

resource "aws_sqs_queue" "image_processing_dlq" {
  name = "image-processor-${var.environment}-dlq"

  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true

  tags = {
    Name        = "image-processor-${var.environment}-dlq"
    Environment = var.environment
    Project     = "image-processor"
  }
}

# ============================================================
# COLA PRINCIPAL DE PROCESAMIENTO
# ============================================================

resource "aws_sqs_queue" "image_processing" {
  name = "image-processor-${var.environment}-queue"

  visibility_timeout_seconds = 180
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.image_processing_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "image-processor-${var.environment}-queue"
    Environment = var.environment
    Project     = "image-processor"
  }
}
