data "aws_ami" "cloudconnector" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["2l8tfysndbav4tv2nfjwak3cu"]
  }
}

resource "aws_instance" "cc_vm" {
  count                       = var.cc_count
  ami                         = var.ami_id != null ? var.ami_id : data.aws_ami.cloudconnector[0].id
  instance_type               = var.ccvm_instance_type
  iam_instance_profile        = var.iam_instance_profile_name
  key_name                    = var.instance_key
  user_data                   = var.userdata
  user_data_replace_on_change = true
  ebs_optimized               = true
  monitoring                  = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.cc_vm_nic_index_0[count.index].id
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = var.ebs_encryption_enabled
    kms_key_id            = var.kms_key_arn
    volume_type           = var.ebs_volume_type
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-cc-vm-${count.index + 1}-ebs"
    })
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                    = "resource-name"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cc-vm-${count.index + 1}"
  })
}

# Forwarding requires source/destination checks to be disabled on the service NIC.
resource "aws_network_interface" "cc_vm_nic_index_0" {
  count             = var.cc_count
  description       = "Cloud Connector forwarding interface"
  subnet_id         = var.aws_cc_subnet_ids[count.index % length(var.aws_cc_subnet_ids)]
  security_groups   = [var.service_interface_sg_id]
  source_dest_check = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cc-vm-${count.index + 1}-FwdIF"
  })
}

resource "aws_network_interface" "cc_vm_nic_index_1" {
  count             = var.cc_count
  description       = "Cloud Connector management interface"
  subnet_id         = var.aws_cc_subnet_ids[count.index % length(var.aws_cc_subnet_ids)]
  security_groups   = [var.management_interface_sg_id]
  source_dest_check = true

  attachment {
    instance     = aws_instance.cc_vm[count.index].id
    device_index = 1
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cc-vm-${count.index + 1}-MgmtIF"
  })
}
