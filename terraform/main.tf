provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_lambda_function" "process_data" {
  filename         = "lambda_functions/lambda_function.zip"
  function_name    = "process_s3_data_lambda"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  role             = var.lambda_role_arn
  source_code_hash = filebase64sha256("lambda_functions/lambda_function.zip")
  environment {
    variables = {
      BUCKET = aws_s3_bucket.data_bucket.bucket
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_data.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_invocation]
}

resource "aws_lambda_permission" "allow_s3_invocation" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_data.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_bucket.arn
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name"
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for Lambda execution"
}
