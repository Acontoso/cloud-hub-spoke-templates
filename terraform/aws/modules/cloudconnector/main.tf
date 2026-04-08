data "aws_ami" "cloudconnector" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["2l8tfysndbav4tv2nfjwak3cu"]
  }

  owners = ["aws-marketplace"]
}

data "aws_ebs_default_kms_key" "current_kms_key" {
  count = 1
}

################################################################################
# Create Cloud Connector VM
################################################################################
resource "aws_instance" "cc_vm" {
  count                = var.cc_count
  ami                  = data.aws_ami.cloudconnector.id
  instance_type        = var.ccvm_instance_type
  iam_instance_profile = aws_iam_instance_profile.cc_host_profile.name
  key_name             = var.instance_key
  user_data            = base64encode(var.userdata)
  ebs_optimized        = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.cc_vm_nic_index_0[count.index].id
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = var.ebs_encryption_enabled
    kms_key_id            = data.aws_ebs_default_kms_key.current_kms_key[0].key_arn
    volume_type           = var.ebs_volume_type
    tags = merge(var.tags,
      { Name = "${var.name_prefix}-cc-vm-${count.index + 1}-ebs" }
    )
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                     = "resource-name"
  }

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-cc-vm-${count.index + 1}" }
  )

  lifecycle {
    ignore_changes = [private_dns_name_options, root_block_device]
  }
}


################################################################################
# Create Cloud Connector Service Interface for "small" CC instances. 
# This interface becomes the Load Balancer VIP interface for "medium" and 
# "large" CC instances.
#
# This primary IP Address of this interface will be used for GWLB Target Group
################################################################################
resource "aws_network_interface" "cc_vm_nic_index_0" {
  count             = var.cc_count
  description       = "cc next hop forwarding interface"
  subnet_id         = element(var.aws_cc_subnet_ids, count.index)
  security_groups   = [var.service_interface_sg_id]
  source_dest_check = false

  tags = merge(var.tags,
  { Name = "${var.name_prefix}-cc-vm-${count.index + 1}-FwdIF" })
}


################################################################################
# Create Cloud Connector Management Interface 
################################################################################
resource "aws_network_interface" "cc_vm_nic_index_1" {
  count             = var.cc_count
  description       = "cc management interface"
  subnet_id         = element(var.aws_cc_subnet_ids, count.index)
  security_groups   = [var.management_interface_sg_id]
  source_dest_check = true

  attachment {
    instance     = aws_instance.cc_vm[count.index].id
    device_index = 1
  }

  tags = merge(var.tags,
  { Name = "${var.name_prefix}-cc-vm-${count.index + 1}-MgmtIF" })
}
