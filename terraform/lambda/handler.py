import boto3
import json

s3 = boto3.client('s3')

def lambda_handler(event, context):
    print("Event:", json.dumps(event))

    for record in event.get('Records', []):
        s3_info = record.get('s3', {})
        bucket_info = s3_info.get('bucket', {})
        object_info = s3_info.get('object', {})
        bucket = bucket_info.get('name')
        key = object_info.get('key')

        if bucket and key:
            new_key = key.replace("uploads/", "processed/")
            s3.copy_object(
                Bucket=bucket,
                CopySource={'Bucket': bucket, 'Key': key},
                Key=new_key
            )
            s3.delete_object(Bucket=bucket, Key=key)
        else:
            print(f"Missing bucket or key in record: {json.dumps(record)}")
            Key=new_key
        s3.delete_object(Bucket=bucket, Key=key)

    return {"statusCode": 200, "body": "Files processed"}
