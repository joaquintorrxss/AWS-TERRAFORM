# ============================================================
# PAQUETE LAMBDA CROP
# ============================================================

data "archive_file" "crop_lambda" {
  type = "zip"

  source_dir = "${path.module}/../../lambda/crop"

  output_path = "${path.root}/.terraform/crop-lambda.zip"
}

# ============================================================
# LAMBDA CROP
# ============================================================

resource "aws_lambda_function" "crop" {
  function_name = "image-processor-${var.environment}-crop"

  filename         = data.archive_file.crop_lambda.output_path
  source_code_hash = data.archive_file.crop_lambda.output_base64sha256

  role    = aws_iam_role.crop_lambda.arn
  handler = "index.handler"
  runtime = "nodejs24.x"

  architectures = ["x86_64"]

  memory_size = 512
  timeout     = 30

  environment {
    variables = {
      BUCKET_NAME      = aws_s3_bucket.images.id
      UPLOADS_PREFIX   = local.uploads_prefix
      PROCESSED_PREFIX = local.processed_prefix
    }
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_group_ids = [
      aws_security_group.lambda.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.crop_lambda_vpc,
    aws_iam_role_policy_attachment.crop_lambda_sqs,
    aws_iam_role_policy.crop_lambda_s3
  ]

  tags = {
    Name        = "image-processor-${var.environment}-crop"
    Environment = var.environment
    Project     = "image-processor"
  }
}
# ============================================================
# SQS -> LAMBDA CROP
# ============================================================

resource "aws_lambda_event_source_mapping" "crop" {
  event_source_arn = aws_sqs_queue.image_processing.arn
  function_name    = aws_lambda_function.crop.arn

  enabled    = true
  batch_size = 1

  depends_on = [
    aws_iam_role_policy_attachment.crop_lambda_sqs
  ]
}