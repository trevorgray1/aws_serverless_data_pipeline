#############################
# IAM Role for Lambda
#############################
resource "aws_iam_role" "lambda_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_rds_policy" {
  name = "lambda-s3-rds-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = ["arn:aws:s3:::${var.bucket_name}/*"]
      },
      {
        Effect   = "Allow"
        Action   = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ]
        Resource = "*"
    
      }
        ,
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

#############################
# Lambda: Init DB Schema
#############################
resource "aws_lambda_function" "init_db" {
  function_name = "init-db"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 60

  filename         = "${path.module}/lambda/init_db/lambda_package.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/init_db/lambda_package.zip")

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = aws_db_instance.app_db.address
      DB_NAME     = "serverlessdb"
      DB_USER     = "appuser"
      DB_PASSWORD = random_password.db_password.result
    }
  }
}

#############################
# Lambda: S3 → RDS
#############################
resource "aws_lambda_function" "s3_to_rds" {
  function_name = "s3-to-rds"
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 30

  filename         = "${path.module}/lambda/S3_to_rds/lambda_package.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/S3_to_rds/lambda_package.zip")

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DB_HOST     = aws_db_instance.app_db.address
      DB_NAME     = "serverlessdb"
      DB_USER     = "appuser"
      DB_PASSWORD = random_password.db_password.result
      S3_BUCKET   = var.bucket_name
    }
  }
}

#############################
# Lambda Permissions for S3 Trigger
#############################
resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowS3Trigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_rds.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.project_bucket.arn
}
