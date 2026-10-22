#################################################
# INSTANCE ID
#################################################

output "instance_id" {

  value = aws_instance.private_ec2.id
}

#################################################
# PRIVATE IP
#################################################

output "private_ip" {

  value = aws_instance.private_ec2.private_ip
}

#################################################
# INSTANCE ARN
#################################################

output "instance_arn" {

  value = aws_instance.private_ec2.arn
}