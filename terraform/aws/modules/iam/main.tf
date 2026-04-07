################################################################################
# Create IAM role and instance profile w/ SSM and Secrets Manager access policies
################################################################################


################################################################################
# Define AssumeRole access for EC2
################################################################################
data "aws_iam_policy_document" "instance_assume_role_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

################################################################################
# Define AWS Managed Secrets Manager Get Secrets Policy
################################################################################
# Retrieve Secret Manager ARN by friendly name
data "aws_secretsmanager_secret" "cc_secret_name" {
  name = var.secret_name
}

# Define policy to GetSecretValue from Secret Name
data "aws_iam_policy_document" "cc_get_secrets_policy_document" {
  version = "2012-10-17"
  statement {
    sid       = "CCPermitGetSecrets"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", ]
    resources = [data.aws_secretsmanager_secret.cc_secret_name.id]
  }
}

# Create Get Secrets Policy
resource "aws_iam_policy" "cc_get_secrets_policy" {
  description = "Policy which permits CCs to retrieve and decrypt the encrypted data from Secrets Manager"
  name        = "${var.name_prefix}-cc-get-secrets"
  policy      = data.aws_iam_policy_document.cc_get_secrets_policy_document.json
}

# Attach Get Secrets Policy to IAM Role
resource "aws_iam_role_policy_attachment" "cc_get_secrets_attachment" {
  policy_arn = aws_iam_policy.cc_get_secrets_policy.arn
  role       = aws_iam_role.cc_node_iam_role.name
}


################################################################################
# Define AWS Managed SSM Session Manager Policy
################################################################################
data "aws_iam_policy_document" "cc_session_manager_policy_document" {
  version = "2012-10-17"
  statement {
    sid    = "CCPermitSSMSessionManager"
    effect = "Allow"
    actions = ["ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

# Create SSM Policy
resource "aws_iam_policy" "cc_session_manager_policy" {
  description = "Policy which permits CCs to register to SSM Manager for Console Connect functionality"
  name        = "${var.name_prefix}-cc-ssm"
  policy      = data.aws_iam_policy_document.cc_session_manager_policy_document.json
}

# Attach SSM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "cc_session_manager_attachment" {
  policy_arn = aws_iam_policy.cc_session_manager_policy.arn
  role       = aws_iam_role.cc_node_iam_role.name
}

################################################################################
# Define AWS Managed CloudWatch Metrics Policy
################################################################################
data "aws_iam_policy_document" "cc_metrics_policy_document" {
  version = "2012-10-17"
  statement {
    sid    = "CCAllowCloudWatchMetricsRW"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
    #Restrict cloudwatch metrics posting only to fixed Zscaler/CloudConnectors namespace
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["Zscaler/CloudConnectors"]
    }
  }

  statement {
    sid    = "CCAllowCloudWatchMetricsRO"
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "CCAllowEC2DescribeTags"
    effect = "Allow"
    actions = [
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cc_metrics_policy" {
  description = "Policy which permits CCs to send custom metrics to CloudWatch"
  name        = "${var.name_prefix}-cc-metrics"
  policy      = data.aws_iam_policy_document.cc_metrics_policy_document.json
}

resource "aws_iam_role_policy_attachment" "cc_metrics_attachment" {
  policy_arn = aws_iam_policy.cc_metrics_policy.arn
  role       = aws_iam_role.cc_node_iam_role.name
}

################################################################################
# Create CC IAM Role and Host/Instance Profile
################################################################################
resource "aws_iam_role" "cc_node_iam_role" {
  name               = "${var.name_prefix}-cc_node_iam_role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  tags               = var.tags
}

# Assign CC IAM Role to Instance Profile for CC instance attachment
resource "aws_iam_instance_profile" "cc_host_profile" {
  name = "${var.name_prefix}-cc-host-profile"
  role = aws_iam_role.cc_node_iam_role.name
  tags = var.tags
}
