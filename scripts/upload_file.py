import os
import sys
import boto3

s3 = boto3.client('s3')

# Check arguments
if len(sys.argv) != 3:
    print("Usage: python upload_file.py <bucket_name> <local_file_path>")
    sys.exit(1)

bucket_name = sys.argv[1]
local_file_path = sys.argv[2]

# Construct the S3 key in the uploads/ folder
key = f"uploads/{os.path.basename(local_file_path)}"

try:
    s3.upload_file(local_file_path, bucket_name, key)
    print(f"✅ Uploaded {local_file_path} to s3://{bucket_name}/{key}")
except Exception as e:
    print(f"❌ Error uploading file: {e}")
