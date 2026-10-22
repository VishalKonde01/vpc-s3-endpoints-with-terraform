#################################################
# EC2 TRUST POLICY
#################################################

data "aws_iam_policy_document" "ec2_assume_role" {

  statement {

    effect = "Allow"

    actions = [

      "sts:AssumeRole"
    ]

    principals {

      type = "Service"

      identifiers = [

        "ec2.amazonaws.com"
      ]
    }
  }
}

#################################################
# IAM ROLE
#################################################

resource "aws_iam_role" "ec2_role" {

  name = "${var.environment}-ec2-ssm-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {

    Name = "${var.environment}-ec2-ssm-role"

    Environment = var.environment
  }
}

#################################################
# INSTANCE PROFILE
#################################################

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "${var.environment}-ec2-instance-profile"

  role = aws_iam_role.ec2_role.name
}


#################################################
# AMAZON SSM MANAGED POLICY
#################################################

resource "aws_iam_role_policy_attachment" "ssm" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#################################################
# S3 READ POLICY DOCUMENT
#################################################

data "aws_iam_policy_document" "s3_read_policy" {

  statement {

    sid = "ListBucket"

    effect = "Allow"

    actions = [

      "s3:ListBucket"
    ]

    resources = [

      var.bucket_arn
    ]
  }

  statement {

    sid = "ReadObjects"

    effect = "Allow"

    actions = [

      "s3:GetObject"
    ]

    resources = [

      "${var.bucket_arn}/*"
    ]
  }
}

#################################################
# CUSTOM POLICY
#################################################

resource "aws_iam_policy" "s3_read_only" {

  name = "${var.environment}-s3-read-policy"

  policy = data.aws_iam_policy_document.s3_read_policy.json
}

#################################################
# ATTACH POLICY
#################################################

resource "aws_iam_role_policy_attachment" "s3_read" {

  role = aws_iam_role.ec2_role.name

  policy_arn = aws_iam_policy.s3_read_only.arn
}