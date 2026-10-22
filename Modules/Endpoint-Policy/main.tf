#################################################
# S3 ENDPOINT POLICY
#################################################

data "aws_iam_policy_document" "s3_endpoint_policy" {

  #################################################
  # ALLOW LIST BUCKET
  #################################################

  statement {

    sid = "AllowListBucket"

    effect = "Allow"

    principals {

      type = "*"

      identifiers = ["*"]
    }

    actions = [

      "s3:ListBucket"
    ]

    resources = [

      var.bucket_arn
    ]
  }

  #################################################
  # ALLOW OBJECT ACCESS
  #################################################

  statement {

    sid = "AllowGetObject"

    effect = "Allow"

    principals {

      type = "*"

      identifiers = ["*"]
    }

    actions = [

      "s3:GetObject"
    ]

    resources = [

      "${var.bucket_arn}/*"
    ]
  }
}