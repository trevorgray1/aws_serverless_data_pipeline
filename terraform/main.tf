provider "aws" {
  region = "us-east-1"
}

# S3 bucket
resource "aws_s3_bucket" "project_bucket" {
  bucket = var.bucket_name
  tags = { Project = "ServerlessDataPipeline" }
}


# Block public access
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.project_bucket.id
  block_public_acls        = true
  block_public_policy      = true
  ignore_public_acls       = true
  restrict_public_buckets  = true
}

# Default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse" {
  bucket = aws_s3_bucket.project_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lambda execution role
resource "aws_iam_role" "lambda_exec_role" {
  name = "serverless_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Lambda permissions policy (S3, CloudWatch, and VPC/ENI)
resource "aws_iam_role_policy" "lambda_full_policy" {
  name = "lambda_full_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 access
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = [
          "${aws_s3_bucket.project_bucket.arn}/uploads/*",
          "${aws_s3_bucket.project_bucket.arn}/processed/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.project_bucket.arn
        Condition = {
          StringLike = {
            "s3:prefix" = ["uploads/", "processed/"]
          }
        }
      },
      # CloudWatch logs
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      # VPC / ENI permissions
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}


# Zip Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

# Lambda function
resource "aws_lambda_function" "s3_processor" {
  function_name = "s3_file_processor"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "S3_to_rds.handler.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# S3 → Lambda trigger
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.project_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.project_bucket.arn
}
