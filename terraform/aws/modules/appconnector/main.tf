data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  parameter_arn = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${trimprefix(var.provisioning_parameter_name, "/")}"
  userdata = templatefile("${path.module}/bootstrap.sh.tftpl", {
    parameter_name = var.provisioning_parameter_name
    region         = data.aws_region.current.name
  })
}

data "aws_ami" "appconnector" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["by1wc5269g0048ix2nqvr0362"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "appconnector" {
  name               = "${var.name_prefix}-ac-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "provisioning" {
  statement {
    sid       = "ReadProvisioningParameter"
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [local.parameter_arn]
  }

  dynamic "statement" {
    for_each = var.provisioning_kms_key_arn == null ? [] : [var.provisioning_kms_key_arn]
    content {
      sid       = "DecryptProvisioningParameter"
      effect    = "Allow"
      actions   = ["kms:Decrypt"]
      resources = [statement.value]

      condition {
        test     = "StringEquals"
        variable = "kms:EncryptionContext:PARAMETER_ARN"
        values   = [local.parameter_arn]
      }
    }
  }
}

resource "aws_iam_role_policy" "provisioning" {
  name   = "${var.name_prefix}-ac-provisioning"
  role   = aws_iam_role.appconnector.id
  policy = data.aws_iam_policy_document.provisioning.json
}

resource "aws_iam_instance_profile" "appconnector" {
  name = "${var.name_prefix}-ac-profile"
  role = aws_iam_role.appconnector.name
  tags = var.tags
}

resource "aws_instance" "ac_vm" {
  count                       = var.ac_count
  ami                         = var.ami_id != null ? var.ami_id : data.aws_ami.appconnector[0].id
  instance_type               = var.acvm_instance_type
  vpc_security_group_ids      = [var.app_connector_sg_id]
  subnet_id                   = var.aws_workload_subnet_ids[count.index % length(var.aws_workload_subnet_ids)]
  key_name                    = var.app_instance_key
  iam_instance_profile        = aws_iam_instance_profile.appconnector.name
  user_data                   = local.userdata
  user_data_replace_on_change = true
  associate_public_ip_address = false
  monitoring                  = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    encrypted             = true
    kms_key_id            = var.ebs_kms_key_arn
    volume_type           = "gp3"
    delete_on_termination = true
    tags                  = merge(var.tags, { Name = "${var.name_prefix}-ac-vm-${count.index + 1}-ebs" })
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ac-vm-${count.index + 1}"
  })

  depends_on = [aws_iam_role_policy.provisioning]
}
