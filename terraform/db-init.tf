#############################
# Invoke init_db Lambda after RDS is ready
#############################

resource "null_resource" "invoke_init_db" {
  # Ensure this runs after both RDS and the Lambda exist
  depends_on = [aws_db_instance.app_db, aws_lambda_function.init_db]

  provisioner "local-exec" {
    command = <<EOT
      aws lambda invoke \
        --function-name ${aws_lambda_function.init_db.function_name} \
        --region ${var.aws_region} \
        /tmp/init_db_output.json
    EOT
    environment = {
      AWS_PROFILE = var.aws_profile
    }
  }
}
