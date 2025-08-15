import boto3
import json

s3 = boto3.client('s3')

def lambda_handler(event, context):
    print("Event:", json.dumps(event))

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        new_key = key.replace("uploads/", "processed/")

        s3.copy_object(
            Bucket=bucket,
            CopySource={'Bucket': bucket, 'Key': key},
            Key=new_key
        )
        s3.delete_object(Bucket=bucket, Key=key)

    return {"statusCode": 200, "body": "Files processed"}
