#################################################
# AMAZON LINUX 2023
#################################################

data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {

    name = "name"

    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {

    name = "virtualization-type"

    values = ["hvm"]
  }
}

#################################################
# EC2 INSTANCE
#################################################

resource "aws_instance" "private_ec2" {

  ami = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type

  subnet_id = var.private_subnet_id

  vpc_security_group_ids = [

    var.ec2_security_group_id
  ]

  iam_instance_profile = var.instance_profile_name

  associate_public_ip_address = false

  #################################################
  # USER DATA
  #################################################

  user_data = file("${path.module}/userdata.sh")

  #################################################
  # ROOT VOLUME
  #################################################

  root_block_device {

    volume_size = 8

    volume_type = "gp3"

    encrypted = true
  }

  #################################################
  # METADATA
  #################################################

  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"
  }

  #################################################
  # TAGS
  #################################################

  tags = {

    Name = "${var.environment}-private-ec2"

    Environment = var.environment

    ManagedBy = "Terraform"

    Project = var.project_name
  }
}