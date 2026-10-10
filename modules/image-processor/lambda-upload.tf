# ============================================================
# PAQUETE LAMBDA UPLOAD
# ============================================================

data "archive_file" "upload_lambda" {
  type = "zip"

  source_dir = "${path.module}/../../lambda/upload"

  output_path = "${path.root}/.terraform/upload-lambda.zip"
}

# ============================================================
# LAMBDA UPLOAD
# ============================================================

resource "aws_lambda_function" "upload" {
  function_name = "image-processor-${var.environment}-upload"

  filename         = data.archive_file.upload_lambda.output_path
  source_code_hash = data.archive_file.upload_lambda.output_base64sha256

  role    = aws_iam_role.upload_lambda.arn
  handler = "index.handler"
  runtime = "nodejs24.x"

  memory_size = 256
  timeout     = 15

  environment {
    variables = {
      BUCKET_NAME    = aws_s3_bucket.images.id
      UPLOADS_PREFIX = local.uploads_prefix
      MAX_FILE_BYTES = "4194304"
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
    aws_iam_role_policy_attachment.upload_lambda_vpc,
    aws_iam_role_policy.upload_lambda_s3
  ]

  tags = {
    Name        = "image-processor-${var.environment}-upload"
    Environment = var.environment
    Project     = "image-processor"
  }
}