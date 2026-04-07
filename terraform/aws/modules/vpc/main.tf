################################################################################
# Network Infrastructure Resources
################################################################################
################################################################################
# VPC
################################################################################
# Create a new VPC
resource "aws_vpc" "vpc" {
  #checkov:skip=CKV2_AWS_11: "Ensure VPC flow logging is enabled in all VPCs" To be done during Micro-segmentation
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-vpc" }
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}

################################################################################
# Internet Gateway
################################################################################
# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-igw" }
  )
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "eip" {
  #checkov:skip=CKV2_AWS_19: "Ensure that all EIP addresses allocated to a VPC are attached to EC2 instances" Horrible advise
  count      = length(aws_subnet.public_subnet[*].id)
  depends_on = [aws_internet_gateway.igw]

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-eip-az${count.index + 1}" }
  )
}

# Create 1 NAT Gateway per Public Subnet.
resource "aws_nat_gateway" "ngw" {
  count         = length(aws_subnet.public_subnet[*].id)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-natgw-az${count.index + 1}" }
  )
}

################################################################################
# Public (NAT Gateway) Subnet & Route Tables
################################################################################
# Create equal number of Public/NAT Subnets to how many Cloud Connector subnets exist. This will not be created if var.byo_ngw is set to True
resource "aws_subnet" "public_subnet" {
  count             = var.az_count
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = element(var.public_subnets, count.index)
  vpc_id            = aws_vpc.vpc.id

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-public-subnet-${count.index + 1}" }
  )
}

# Create a public Route Table towards IGW. This will not be created if var.byo_ngw is set to True
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-public-rt" }
  )
}

# Create equal number of Route Table associations to how many Public subnets exist.
resource "aws_route_table_association" "public_rt_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

################################################################################
# Private (Cloud Connector) Subnet & Route Tables
################################################################################
# Create subnet for CC network in X availability zones per az_count variable
resource "aws_subnet" "cc_subnet" {
  count                                       = var.az_count
  availability_zone                           = data.aws_availability_zones.available.names[count.index]
  cidr_block                                  = element(var.cc_subnets, count.index)
  vpc_id                                      = aws_vpc.vpc.id
  enable_resource_name_dns_a_record_on_launch = true

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-cc-subnet-${count.index + 1}" }
  )
}

# Create Route Tables for CC subnets pointing to NAT Gateway resource in each AZ or however many were specified. Optionally, point directly to IGW for public deployments
resource "aws_route_table" "cc_rt" {
  count  = length(aws_subnet.cc_subnet[*].id)
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-cc-rt-${count.index + 1}" }
  )
}

resource "aws_route" "default_route_cc_rt" {
  count                  = length(aws_subnet.cc_subnet[*].id)
  route_table_id         = aws_route_table.cc_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
}

locals {
  cc_routes = {
    #Nested arrays are flatterned into one list, combine a series of list of maps into a single list with all maps
    for pair in flatten([
      #Iterate over each route table (there are three, 1 for each subnet in avz), whereby rt_key is the index and rt is the route table object
      #Creating a list of maps hence the "[" List per route table. Will combine into a single one with flatten
      for rt_key, rt in aws_route_table.cc_rt : [
        #The second loop iterates over the list of static routes defined in the variable
        for route_cidr in var.static_routes_tgw : {
          #Create a map for each route to create specific to the route table
          key                    = "${rt_key}-${route_cidr}" #unique key for each route
          route_table_id         = rt.id
          destination_cidr_block = route_cidr
        }
      ] #Closes the list of maps. Now convert list to map whereby the key is the unique key created above
      #Result is a map of maps, with the key being the unique key created above
      ]) : pair.key => {
      route_table_id         = pair.route_table_id
      destination_cidr_block = pair.destination_cidr_block
    }
  }
}

resource "aws_route" "custom_routes_cc_rt" {
  for_each               = local.cc_routes
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.silk_tgw.id
}

# CC subnet Route Table Association
resource "aws_route_table_association" "cc_rt_asssociation" {
  count          = length(aws_subnet.cc_subnet[*].id)
  subnet_id      = aws_subnet.cc_subnet[count.index].id
  route_table_id = aws_route_table.cc_rt[count.index].id
}

################################################################################
# Workload Subnet & Route Tables
################################################################################
# Create subnet for Workloads in X availability zones per az_count variable
resource "aws_subnet" "workload_subnet" {
  count                                       = var.az_count
  availability_zone                           = data.aws_availability_zones.available.names[count.index]
  cidr_block                                  = element(var.workload_subnets, count.index)
  vpc_id                                      = aws_vpc.vpc.id
  enable_resource_name_dns_a_record_on_launch = true

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-workload-subnet-${count.index + 1}" }
  )
}

# Create Route Tables for CC subnets pointing to NAT Gateway resource in each AZ or however many were specified. Optionally, point directly to IGW for public deployments
resource "aws_route_table" "workload_rt" {
  count  = length(aws_subnet.workload_subnet[*].id)
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-workload-rt-${count.index + 1}" }
  )
}

resource "aws_route" "default_route_workload_rt" {
  count                  = length(aws_subnet.workload_subnet[*].id)
  route_table_id         = aws_route_table.workload_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
}

locals {
  workload_routes = {
    for pair in flatten([
      for rt_key, rt in aws_route_table.workload_rt : [
        for route_cidr in var.static_routes_tgw : {
          key                    = "${rt_key}-${route_cidr}"
          route_table_id         = rt.id
          destination_cidr_block = route_cidr
        }
      ]
      ]) : pair.key => {
      route_table_id         = pair.route_table_id
      destination_cidr_block = pair.destination_cidr_block
    }
  }
}

resource "aws_route" "custom_routes_workload_rt" {
  for_each               = local.workload_routes
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.silk_tgw.id
}

# CC subnet Route Table Association
resource "aws_route_table_association" "workload_rt_asssociation" {
  count          = length(aws_subnet.workload_subnet[*].id)
  subnet_id      = aws_subnet.workload_subnet[count.index].id
  route_table_id = aws_route_table.workload_rt[count.index].id
}

################################################################################
# Inspection VPC Transit Gateway Subnet & Route Tables
################################################################################
# Create tgw reserved subnets in X availability zones per az_count variable or minimum of 2; whichever is greater
resource "aws_subnet" "tgw_subnet" {
  count             = var.az_count
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = element(var.tgw_subnets, count.index)
  vpc_id            = aws_vpc.vpc.id

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-tgw-subnet-${count.index + 1}" }
  )
}

resource "aws_route_table" "tgw_rt" {
  count  = length(aws_subnet.tgw_subnet[*].id)
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-tgw-to-cc-${count.index + 1}-rt" }
  )
}

resource "aws_route_table_association" "tgw_rt_asssociation" {
  count          = length(aws_subnet.tgw_subnet[*].id)
  subnet_id      = aws_subnet.tgw_subnet[count.index].id
  route_table_id = aws_route_table.tgw_rt[count.index].id
}

resource "aws_route" "tgw_route_vpc_endpoint" {
  count                  = length(aws_route_table.tgw_rt[*].id)
  route_table_id         = aws_route_table.tgw_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlb_vpce[count.index].id
}

locals {
  tgw_routes = {
    for pair in flatten([
      for rt_key, rt in aws_route_table.tgw_rt : [
        for route_cidr in var.static_routes_tgw : {
          key                    = "${rt_key}-${route_cidr}"
          route_table_id         = rt.id
          destination_cidr_block = route_cidr
        }
      ]
      ]) : pair.key => {
      route_table_id         = pair.route_table_id
      destination_cidr_block = pair.destination_cidr_block
    }
  }
}

resource "aws_route" "custom_routes_tgw_rt" {
  for_each               = local.tgw_routes
  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.silk_tgw.id
}

########################EC2 Instance Connect###############################
resource "aws_security_group" "ec2_instance_endpoint_security_group" {
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource" - Attached to the below - FP
  name        = "EC2 Instance Connect Endpoint Security Group"
  description = "Allow Instance Connect to hit other endpoints for TCP port forwarding"
  vpc_id      = aws_vpc.vpc.id
  tags        = var.tags
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_ec2_endpoint" {
  security_group_id = aws_security_group.ec2_instance_endpoint_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  description       = "Default out IPv4"
  tags              = var.tags
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6_ec2_endpoint" {
  security_group_id = aws_security_group.ec2_instance_endpoint_security_group.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  description       = "Default out IPv6"
  tags              = var.tags
}

resource "aws_ec2_instance_connect_endpoint" "ec2_instance_connect" {
  subnet_id          = aws_subnet.workload_subnet[0].id
  security_group_ids = [aws_security_group.ec2_instance_endpoint_security_group.id]
  preserve_client_ip = false
  tags               = var.tags
}