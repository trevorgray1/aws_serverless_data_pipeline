import boto3
import sys

# S3 client
s3 = boto3.client('s3')

def download_file(bucket_name, object_name, dest_path=None):
    if dest_path is None:
        dest_path = object_name  # save with same name
    try:
        s3.download_file(bucket_name, object_name, dest_path)
        print(f"✅ Downloaded s3://{bucket_name}/{object_name} to {dest_path}")
    except Exception as e:
        print(f"❌ Error downloading file: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python download_file.py <bucket_name> <object_name>")
        sys.exit(1)

    bucket = sys.argv[1]
    object_name = sys.argv[2]
    download_file(bucket, object_name)
