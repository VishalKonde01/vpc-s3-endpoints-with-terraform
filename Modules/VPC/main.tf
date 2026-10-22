#################################################
# LOCAL TAGS
#################################################

locals {

  common_tags = {

    Environment = var.environment

    ManagedBy = "Terraform"

    Project = "ssm-vpc-endpoint-demo"
  }
}

#################################################
# VPC
#################################################

resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  enable_dns_support = true

  enable_dns_hostnames = true

  tags = merge(

    local.common_tags,

    {

      Name = "${var.environment}-vpc"
    }
  )
}

#################################################
# INTERNET GATEWAY
#################################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id

  tags = merge(

    local.common_tags,

    {

      Name = "${var.environment}-igw"
    }
  )
}

#################################################
# PUBLIC SUBNETS
#################################################

resource "aws_subnet" "public" {

  count = length(var.public_subnets)

  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnets[count.index]

  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(

    local.common_tags,

    {

      Name = "${var.environment}-public-${count.index + 1}"
    }
  )
}

#################################################
# PRIVATE SUBNETS
#################################################

resource "aws_subnet" "private" {

  count = length(var.private_subnets)

  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnets[count.index]

  availability_zone = var.availability_zones[count.index]

  tags = merge(

    local.common_tags,

    {

      Name = "${var.environment}-private-${count.index + 1}"
    }
  )
}

#################################################
# PUBLIC ROUTE TABLE
#################################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(

    local.common_tags,

    {

      Name = "${var.environment}-public-rt"
    }
  )
}

#################################################
# PRIVATE ROUTE TABLE
#################################################

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id

  tags = merge(

    local.common_tags,

    {

      Name = "${var.environment}-private-rt"
    }
  )
}

#################################################
# PUBLIC ROUTE TABLE ASSOCIATIONS
#################################################

resource "aws_route_table_association" "public" {

  count = length(var.public_subnets)

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id
}

#################################################
# PRIVATE ROUTE TABLE ASSOCIATIONS
#################################################

resource "aws_route_table_association" "private" {

  count = length(var.private_subnets)

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private.id
}



#################################################
# ENDPOINT SECURITY GROUP
#################################################

resource "aws_security_group" "endpoint_sg" {

  name = "${var.environment}-endpoint-sg"

  description = "Security Group for VPC Interface Endpoints"

  vpc_id = aws_vpc.main.id

  ingress {

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {

    Name        = "${var.environment}-endpoint-sg"
    Environment = var.environment
  }
}

#################################################
# S3 GATEWAY ENDPOINT
#################################################

resource "aws_vpc_endpoint" "s3" {

  vpc_id = aws_vpc.main.id

  service_name = "com.amazonaws.${var.aws_region}.s3"

  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]

  tags = {

    Name        = "${var.environment}-s3-endpoint"
    Environment = var.environment
  }
}

#################################################
# SSM ENDPOINT
#################################################

resource "aws_vpc_endpoint" "ssm" {

  vpc_id = aws_vpc.main.id

  service_name = "com.amazonaws.${var.aws_region}.ssm"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  private_dns_enabled = true

  tags = {

    Name        = "${var.environment}-ssm-endpoint"
    Environment = var.environment
  }
}

#################################################
# EC2 MESSAGES ENDPOINT
#################################################

resource "aws_vpc_endpoint" "ec2messages" {

  vpc_id = aws_vpc.main.id

  service_name = "com.amazonaws.${var.aws_region}.ec2messages"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  private_dns_enabled = true

  tags = {

    Name        = "${var.environment}-ec2messages-endpoint"
    Environment = var.environment
  }
}

#################################################
# SSM MESSAGES ENDPOINT
#################################################

resource "aws_vpc_endpoint" "ssmmessages" {

  vpc_id = aws_vpc.main.id

  service_name = "com.amazonaws.${var.aws_region}.ssmmessages"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  private_dns_enabled = true

  tags = {

    Name        = "${var.environment}-ssmmessages-endpoint"
    Environment = var.environment
  }
}

#################################################
# STS ENDPOINT
#################################################

resource "aws_vpc_endpoint" "sts" {

  vpc_id = aws_vpc.main.id

  service_name = "com.amazonaws.${var.aws_region}.sts"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  private_dns_enabled = true

  tags = {

    Name        = "${var.environment}-sts-endpoint"
    Environment = var.environment
  }
}

#################################################
# EC2 API ENDPOINT
#################################################

resource "aws_vpc_endpoint" "ec2" {

  vpc_id = aws_vpc.main.id

  service_name = "com.amazonaws.${var.aws_region}.ec2"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.endpoint_sg.id
  ]

  private_dns_enabled = true

  tags = {

    Name        = "${var.environment}-ec2-endpoint"
    Environment = var.environment
  }
}


resource "aws_network_acl" "private" {

  vpc_id = aws_vpc.main.id

  subnet_ids = aws_subnet.private[*].id

  #################################################
  # HTTPS INBOUND RESPONSE
  #################################################

  ingress {

    rule_no = 100

    protocol = "tcp"

    action = "allow"

    cidr_block = "0.0.0.0/0"

    from_port = 443

    to_port = 443
  }

  #################################################
  # EPHEMERAL RETURN TRAFFIC
  #################################################

  ingress {

    rule_no = 110

    protocol = "tcp"

    action = "allow"

    cidr_block = "0.0.0.0/0"

    from_port = 1024

    to_port = 65535
  }

  #################################################
  # HTTPS OUTBOUND
  #################################################

  egress {

    rule_no = 100

    protocol = "tcp"

    action = "allow"

    cidr_block = "0.0.0.0/0"

    from_port = 443

    to_port = 443
  }

  #################################################
  # DNS UDP
  #################################################

  egress {

    rule_no = 110

    protocol = "udp"

    action = "allow"

    cidr_block = var.vpc_cidr

    from_port = 53

    to_port = 53
  }

  #################################################
  # DNS TCP
  #################################################

  egress {

    rule_no = 120

    protocol = "tcp"

    action = "allow"

    cidr_block = var.vpc_cidr

    from_port = 53

    to_port = 53
  }

  #################################################
  # EPHEMERAL RETURN
  #################################################

  egress {

    rule_no = 130

    protocol = "tcp"

    action = "allow"

    cidr_block = "0.0.0.0/0"

    from_port = 1024

    to_port = 65535
  }

  tags = {

    Name = "${var.environment}-private-nacl"

    Environment = var.environment
  }
}