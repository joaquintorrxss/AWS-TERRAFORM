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

# ============================================================
# POLITICA S3 -> SQS
# ============================================================

data "aws_iam_policy_document" "s3_to_sqs" {
  statement {
    sid    = "AllowS3ToSendMessages"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.image_processing.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.images.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sqs_queue_policy" "s3_to_sqs" {
  queue_url = aws_sqs_queue.image_processing.id
  policy    = data.aws_iam_policy_document.s3_to_sqs.json
}
