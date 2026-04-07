data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


resource "aws_vpc_endpoint_service" "gwlb_vpce_service" {
  acceptance_required        = false
  allowed_principals         = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:root"]
  gateway_load_balancer_arns = [var.gwlb_arn]
  region                     = data.aws_region.current.name
  supported_ip_address_types = ["ipv4"]
  tags = merge(var.tags,
    { Name = "${var.name_prefix}-cc-gwlb-vpce-service" }
  )
}

################################################################################
# Create the GWLB Endpoint ENIs per list of subnet IDs specified - might fail
################################################################################
resource "aws_vpc_endpoint" "gwlb_vpce" {
  count             = length(var.aws_cc_subnet_ids)
  service_name      = aws_vpc_endpoint_service.gwlb_vpce_service.service_name
  subnet_ids        = [element(var.aws_cc_subnet_ids, count.index)]
  vpc_endpoint_type = aws_vpc_endpoint_service.gwlb_vpce_service.service_type
  vpc_id            = var.vpc_id

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-client-vpce-az${count.index + 1}" }
  )
}
