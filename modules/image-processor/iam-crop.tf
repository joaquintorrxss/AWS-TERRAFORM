# ============================================================
# IAM - LAMBDA CROP
# ============================================================

data "aws_iam_policy_document" "crop_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "crop_lambda" {
  name               = "image-processor-${var.environment}-crop-role"
  assume_role_policy = data.aws_iam_policy_document.crop_lambda_assume_role.json

  tags = {
    Environment = var.environment
    Project     = "image-processor"
  }
}

# Permite a Lambda trabajar dentro de las subnets privadas
# y escribir logs en CloudWatch.
resource "aws_iam_role_policy_attachment" "crop_lambda_vpc" {
  role       = aws_iam_role.crop_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Permisos requeridos para consumir mensajes desde SQS.
resource "aws_iam_role_policy_attachment" "crop_lambda_sqs" {
  role       = aws_iam_role.crop_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# Acceso limitado a las rutas necesarias dentro del bucket.
data "aws_iam_policy_document" "crop_lambda_s3" {
  statement {
    sid    = "ReadOriginalImages"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.images.arn}/${local.uploads_prefix}*"
    ]
  }

  statement {
    sid    = "WriteProcessedImages"
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.images.arn}/${local.processed_prefix}*"
    ]
  }
}

resource "aws_iam_role_policy" "crop_lambda_s3" {
  name   = "image-processor-${var.environment}-crop-s3"
  role   = aws_iam_role.crop_lambda.id
  policy = data.aws_iam_policy_document.crop_lambda_s3.json
}