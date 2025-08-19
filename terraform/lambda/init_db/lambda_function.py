import os
import psycopg2

def lambda_handler(event, context):
    # Grab environment variables
    host = os.environ["DB_HOST"]
    dbname = os.environ["DB_NAME"]
    user = os.environ["DB_USER"]
    password = os.environ["DB_PASSWORD"]

    conn = psycopg2.connect(
        host=host,
        database=dbname,
        user=user,
        password=password
    )
    cur = conn.cursor()

    # Execute schema creation SQL
    cur.execute("""
        CREATE EXTENSION IF NOT EXISTS pgcrypto;
        CREATE TABLE IF NOT EXISTS file_metadata (
            file_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            file_name TEXT NOT NULL,
            s3_key TEXT NOT NULL,
            bucket_name TEXT NOT NULL,
            upload_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            file_size BIGINT,
            file_type TEXT,
            uploader TEXT,
            processed_time TIMESTAMP
        );
    """)
    conn.commit()
    cur.close()
    conn.close()

    return {"status": "Schema initialization complete"}
