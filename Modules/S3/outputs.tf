#################################################
# BUCKET NAME
#################################################

output "bucket_name" {

  value = aws_s3_bucket.private_bucket.bucket
}

#################################################
# BUCKET ARN
#################################################

output "bucket_arn" {

  value = aws_s3_bucket.private_bucket.arn
}

#################################################
# TEST FILE
#################################################

output "test_file" {

  value = aws_s3_object.test_file.key
}