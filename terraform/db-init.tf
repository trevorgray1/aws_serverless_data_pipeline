resource "null_resource" "init_db" {
  depends_on = [aws_db_instance.app_db]

  provisioner "local-exec" {
    command = <<EOT
      PGPASSWORD=${var.db_password} psql \
        --host=${aws_db_instance.app_db.address} \
        --port=5432 \
        --username=appuser \
        --dbname=serverlessdb \
        -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;
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
            );"
    EOT
  }
}
