variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket used by Lambdas"
  type        = string
  default     = "aws-serverless-app-tgray"
}

variable "project_name" {
  description = "Project name prefix for resource naming"
  type        = string
}

variable "db_password" {
  description = "Postgres DB password"
  type        = string
  sensitive   = true
}
variable "aws_profile" {
  default = "default"
}
