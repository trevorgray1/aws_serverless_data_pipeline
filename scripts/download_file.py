import sys
import boto3
import os

s3 = boto3.client('s3')

# Check arguments
if len(sys.argv) != 3:
    print("Usage: python download_file.py <bucket_name> <local_file_path>")
    sys.exit(1)

bucket_name = sys.argv[1]
local_file_path = sys.argv[2]

# Construct the S3 key based on processed/ folder
key = f"processed/{os.path.basename(local_file_path)}"

try:
    s3.download_file(bucket_name, key, local_file_path)
    print(f"✅ Downloaded s3://{bucket_name}/{key} to {local_file_path}")
except Exception as e:
    print(f"❌ Error downloading file: {e}")
