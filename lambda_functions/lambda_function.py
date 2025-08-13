import json
import boto3
import urllib.parse

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'])
        try:
            response = s3.get_object(Bucket=bucket, Key=key)
            data = response['Body'].read().decode('utf-8')
            # Here you would process the data (CSV, JSON, etc)
            print(f"Processed file from bucket: {bucket}, key: {key}")
        except Exception as e:
            print(f"Error processing object {key} from bucket {bucket}: {str(e)}")
            raise e
    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }
