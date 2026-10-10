# ============================================================
# IAM - LAMBDA UPLOAD
# ============================================================

data "aws_iam_policy_document" "upload_lambda_assume_role" {
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

resource "aws_iam_role" "upload_lambda" {
  name               = "image-processor-${var.environment}-upload-role"
  assume_role_policy = data.aws_iam_policy_document.upload_lambda_assume_role.json

  tags = {
    Environment = var.environment
    Project     = "image-processor"
  }
}

# Permite a Lambda crear ENI dentro de la VPC y escribir logs.
resource "aws_iam_role_policy_attachment" "upload_lambda_vpc" {
  role       = aws_iam_role.upload_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# La Lambda Upload solo necesita escribir dentro de uploads/.
data "aws_iam_policy_document" "upload_lambda_s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.images.arn}/${local.uploads_prefix}*"
    ]
  }
}

resource "aws_iam_role_policy" "upload_lambda_s3" {
  name   = "image-processor-${var.environment}-upload-s3"
  role   = aws_iam_role.upload_lambda.id
  policy = data.aws_iam_policy_document.upload_lambda_s3.json
}