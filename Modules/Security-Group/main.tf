#################################################
# LOCAL TAGS
#################################################

locals {

  common_tags = {

    Environment = var.environment

    ManagedBy   = "Terraform"

    Project     = var.project_name
  }
}

#################################################
# PRIVATE EC2 SECURITY GROUP
#################################################

resource "aws_security_group" "ec2" {

  name        = "${var.environment}-private-ec2-sg"

  description = "Private EC2 Security Group"

  vpc_id = var.vpc_id

  #################################################
  # NO INBOUND
  #################################################

  #################################################
  # DNS TO VPC RESOLVER
  #################################################

  egress {

    description = "DNS UDP"

    from_port = 53

    to_port = 53

    protocol = "udp"

    cidr_blocks = [
      var.vpc_cidr
    ]
  }

  egress {

    description = "DNS TCP"

    from_port = 53

    to_port = 53

    protocol = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]
  }

  #################################################
  # HTTPS TO AWS SERVICES
  #################################################

  egress {

    description = "HTTPS Outbound"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = merge(

    local.common_tags,

    {

      Name = "${var.environment}-private-ec2-sg"
    }
  )
}