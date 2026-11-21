data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.flow_logs_enabled ? 1 : 0
  name              = "/aws/vpc/${aws_vpc.vpc.id}/flow-logs"
  retention_in_days = var.flow_log_retention_days
  tags              = var.tags
}

resource "aws_iam_role" "flow_logs" {
  count       = var.flow_logs_enabled ? 1 : 0
  name_prefix = "${substr(var.name_prefix, 0, 26)}-flow-logs-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
        ArnLike = {
          "aws:SourceArn" = "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"
        }
      }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.flow_logs_enabled ? 1 : 0
  name  = "cloudwatch-flow-log-delivery"
  role  = aws_iam_role.flow_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.flow_logs[0].arn}:log-stream:*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:DescribeLogStreams"]
        Resource = aws_cloudwatch_log_group.flow_logs[0].arn
      }
    ]
  })
}

resource "aws_flow_log" "vpc" {
  count                = var.flow_logs_enabled ? 1 : 0
  vpc_id               = aws_vpc.vpc.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn         = aws_iam_role.flow_logs[0].arn
  tags                 = var.tags
  depends_on           = [aws_iam_role_policy.flow_logs]
}
