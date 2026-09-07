data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count = var.use_ssm ? 1 : 0

  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  count = var.enable_cloudwatch_agent ? 1 : 0

  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "runtime_config_read" {
  statement {
    sid = "ReadRuntimeConfigParameters"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = var.allowed_ssm_parameter_arns
  }
}

resource "aws_iam_policy" "runtime_config_read" {
  name        = "${var.name_prefix}-runtime-config-read"
  description = "Allow EC2 to read only this application's runtime parameters."
  policy      = data.aws_iam_policy_document.runtime_config_read.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "runtime_config_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.runtime_config_read.arn
}

data "aws_iam_policy_document" "ecr_pull" {
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/munch-catering-backend",
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/munch-catering-frontend"
    ]
  }
}

resource "aws_iam_policy" "ecr_pull" {
  name        = "${var.name_prefix}-ecr-pull"
  description = "Allow EC2 to pull application images from ECR."
  policy      = data.aws_iam_policy_document.ecr_pull.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ecr_pull.arn
}

data "aws_iam_policy_document" "s3_media_access" {
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0

  statement {
    sid    = "S3BucketList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = var.s3_bucket_arns
  }

  statement {
    sid    = "S3ObjectCrud"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [for arn in var.s3_bucket_arns : "${arn}/*"]
  }
}

resource "aws_iam_policy" "s3_media_access" {
  count       = length(var.s3_bucket_arns) > 0 ? 1 : 0
  name        = "${var.name_prefix}-s3-media-access"
  description = "Scoped S3 access for portfolio media files."
  policy      = data.aws_iam_policy_document.s3_media_access[0].json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "s3_media_access" {
  count      = length(var.s3_bucket_arns) > 0 ? 1 : 0
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.s3_media_access[0].arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-profile"
  })
}