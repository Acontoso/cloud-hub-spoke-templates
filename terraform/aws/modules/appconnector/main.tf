data "aws_ami" "appconnector" {
  most_recent = false

  filter {
    name   = "product-code"
    values = ["by1wc5269g0048ix2nqvr0362"]
  }

  filter {
    name   = "image-id"
    values = ["ami-0f98002ff03477c9f"]
  }

  owners = ["aws-marketplace"]
}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "aws_instance" "ac_vm" {
  count                  = var.ac_count
  ami                    = data.aws_ami.appconnector.id
  availability_zone      = data.aws_availability_zones.available.names[count.index]
  instance_type          = var.acvm_instance_type
  vpc_security_group_ids = [var.app_connector_sg_id]
  subnet_id              = element(var.aws_workload_subnet_ids, count.index)
  key_name               = var.app_instance_key
  user_data              = base64encode(var.appuserdata)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-ac-vm-${count.index + 1}" }
  )
}
