import boto3
import argparse
import os

def upload_file(bucket, file_path):
    s3 = boto3.client('s3')
    file_name = os.path.basename(file_path)
    s3.upload_file(file_path, bucket, file_name)
    print(f"Uploaded {file_path} to s3://{bucket}/{file_name}")

def download_file(bucket, file_name, download_path):
    s3 = boto3.client('s3')
    s3.download_file(bucket, file_name, download_path)
    print(f"Downloaded s3://{bucket}/{file_name} to {download_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='S3 upload/download test script')
    parser.add_argument('--upload', help='File to upload')
    parser.add_argument('--bucket', required=True, help='S3 bucket name')
    parser.add_argument('--download', help='File to download')
    parser.add_argument('--download-path', help='Download destination path', default='.')

    args = parser.parse_args()

    if args.upload:
        upload_file(args.bucket, args.upload)

    if args.download:
        download_file(args.bucket, args.download, args.download_path)
