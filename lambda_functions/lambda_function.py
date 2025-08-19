import boto3
import os

s3 = boto3.client("s3")

def lambda_handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]

        print(f"Processing file: s3://{bucket}/{key}")

        # Skip if not in uploads/
        if not key.startswith("uploads/"):
            print(f"Skipping {key}, not in uploads/")
            continue

        # Define processed key
        filename = key.split("/")[-1]
        processed_key = f"processed/{filename}"

        try:
            # Copy object to processed/
            s3.copy_object(
                Bucket=bucket,
                CopySource={"Bucket": bucket, "Key": key},
                Key=processed_key
            )
            print(f"Copied {key} → {processed_key}")

        except Exception as e:
            print(f"Error processing {key}: {str(e)}")
            raise e
