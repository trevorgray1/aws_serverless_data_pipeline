# AWS Serverless Data Pipeline Project

## Overview
This project demonstrates building a serverless data processing pipeline on AWS using Lambda, S3, API Gateway, and RDS/PostgreSQL. It includes Python scripts, SQL setup, Terraform infrastructure, and sample data.

## Weekly Plan

### Week 1: AWS CLI and Python Setup
- Install AWS CLI v2 and configure it
- Setup Python virtual environment and install boto3
- Create an S3 bucket
- Run test scripts to upload/download files from S3

### Week 2: Build Lambda Functions in Python
- Write Lambda functions triggered by S3 upload events
- Implement simple data processing inside Lambda (e.g., parse CSV)
- Test Lambda invocation manually

### Week 3: Store Processed Data in Database
- Setup AWS RDS PostgreSQL or DynamoDB tables
- Extend Lambda to insert processed data into the database
- Write basic SQL queries to validate data

### Week 4: API Gateway Setup
- Create REST API endpoints using AWS API Gateway
- Connect API Gateway to Lambda functions for querying data

### Week 5: Query Data via API
- Implement Lambda functions to query the database and return JSON responses
- Test API endpoints with tools like Postman or curl

### Week 6: (Optional) Automate Deployment with Terraform
- Learn basic Terraform concepts and syntax
- Deploy your infrastructure (S3, Lambda, API Gateway, RDS) using Terraform scripts

### Week 7: Add Monitoring and Logging
- Enable CloudWatch logging for Lambda functions
- Add Python logging and error handling inside Lambda
- Set up CloudWatch alarms for error rates

### Week 8: Final Testing, Documentation, and Cleanup
- Perform end-to-end testing of the full pipeline
- Write usage documentation and setup instructions
- Clean up code, add comments, and prepare for future enhancements

## File Overview
- `lambda_functions/`: Python Lambda scripts
- `sql/`: PostgreSQL setup scripts
- `terraform/`: Terraform files (optional)
- `data/`: Sample CSV data files
- `README.md`: This file

## Getting Started

### AWS CLI Setup
- Install AWS CLI v2: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
- Configure with `aws configure` (you'll need access key, secret key, region)
- Verify setup: `aws s3 ls`

### Python Environment Setup
- Install Python 3.8+
- Create virtual environment: `python3 -m venv venv`
- Activate it:
  - Linux/macOS: `source venv/bin/activate`
  - Windows: `venv\Scripts\activate`
- Install boto3: `pip install boto3`

### S3 Bucket Test Script (lambda_functions/s3_test.py)
This script uploads and downloads a file to S3 to verify access.

Run example:
```bash
python s3_test.py --upload data/sample_data.csv --bucket your-bucket-name
```

