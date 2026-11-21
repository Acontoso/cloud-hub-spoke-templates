data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_secretsmanager_secret" "cc_secret_name" {
  name = var.secret_name
}

data "aws_iam_policy_document" "cc_get_secrets_policy_document" {
  statement {
    sid       = "CCPermitGetSecrets"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [data.aws_secretsmanager_secret.cc_secret_name.arn]
  }

  dynamic "statement" {
    for_each = var.secret_kms_key_arn == null ? [] : [var.secret_kms_key_arn]
    content {
      sid       = "DecryptProvisioningSecret"
      effect    = "Allow"
      actions   = ["kms:Decrypt"]
      resources = [statement.value]

      condition {
        test     = "StringEquals"
        variable = "kms:EncryptionContext:SecretARN"
        values   = [data.aws_secretsmanager_secret.cc_secret_name.arn]
      }
    }
  }
}

resource "aws_iam_policy" "cc_get_secrets_policy" {
  name        = "${var.name_prefix}-cc-get-secrets"
  description = "Read the Cloud Connector provisioning secret."
  policy      = data.aws_iam_policy_document.cc_get_secrets_policy_document.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "cc_get_secrets_attachment" {
  policy_arn = aws_iam_policy.cc_get_secrets_policy.arn
  role       = aws_iam_role.cc_node_iam_role.name
}

data "aws_iam_policy_document" "cc_session_manager_policy_document" {
  statement {
    sid    = "CCPermitSSMSessionManager"
    effect = "Allow"
    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cc_session_manager_policy" {
  name        = "${var.name_prefix}-cc-ssm"
  description = "Register the Cloud Connector agent and establish SSM sessions."
  policy      = data.aws_iam_policy_document.cc_session_manager_policy_document.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "cc_session_manager_attachment" {
  policy_arn = aws_iam_policy.cc_session_manager_policy.arn
  role       = aws_iam_role.cc_node_iam_role.name
}

data "aws_iam_policy_document" "cc_metrics_policy_document" {
  statement {
    sid       = "CCAllowCloudWatchMetricsRW"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["Zscaler/CloudConnectors"]
    }
  }

  statement {
    sid       = "CCAllowCloudWatchMetricsRO"
    effect    = "Allow"
    actions   = ["cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics"]
    resources = ["*"]
  }

  statement {
    sid       = "CCAllowEC2DescribeTags"
    effect    = "Allow"
    actions   = ["ec2:DescribeTags"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cc_metrics_policy" {
  name        = "${var.name_prefix}-cc-metrics"
  description = "Publish appliance metrics and discover instance tags."
  policy      = data.aws_iam_policy_document.cc_metrics_policy_document.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "cc_metrics_attachment" {
  policy_arn = aws_iam_policy.cc_metrics_policy.arn
  role       = aws_iam_role.cc_node_iam_role.name
}

resource "aws_iam_role" "cc_node_iam_role" {
  name               = "${var.name_prefix}-cc_node_iam_role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "cc_host_profile" {
  name = "${var.name_prefix}-cc-host-profile"
  role = aws_iam_role.cc_node_iam_role.name
  tags = var.tags
}
