import boto3
import sys

# S3 client
s3 = boto3.client('s3')

def upload_file(bucket_name, file_path, object_name=None):
    if object_name is None:
        object_name = file_path.split("/")[-1]  # default to filename
    try:
        s3.upload_file(file_path, bucket_name, object_name)
        print(f"✅ Uploaded {file_path} to s3://{bucket_name}/{object_name}")
    except Exception as e:
        print(f"❌ Error uploading file: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python upload_file.py <bucket_name> <file_path>")
        sys.exit(1)

    bucket = sys.argv[1]
    file_path = sys.argv[2]
    upload_file(bucket, file_path)
