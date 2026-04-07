################################################################################
# Create Security Group and Rules for Cloud Connector Management Interfaces
################################################################################
resource "aws_security_group" "cc_mgmt_sg" {
  name        = "${var.name_prefix}-cc-mgmt-sg"
  description = "Security group for Cloud Connector management interface"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-cc-mgmt-sg" }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cc_mgmt_ingress_ssh" {
  description       = "SSH to CC management"
  security_group_id = aws_security_group.cc_mgmt_sg.id
  cidr_ipv4         = var.vpc_id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "cc_mgmt_ingress_ssh_dev" {
  security_group_id = aws_security_group.cc_mgmt_sg.id
  cidr_ipv4         = "10.200.6.105/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#Default required egress connectivity
resource "aws_vpc_security_group_egress_rule" "egress_cc_mgmt_tcp_443" {
  description       = "CC outbound TCP 443"
  security_group_id = aws_security_group.cc_mgmt_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_cc_mgmt_udp_123" {
  description       = "CC Mgmt outbound NTP"
  security_group_id = aws_security_group.cc_mgmt_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 123
  ip_protocol       = "udp"
  to_port           = 123
}

resource "aws_vpc_security_group_egress_rule" "egress_cc_mgmt_pkg_repo" {
  description       = "CC Mgmt outbound Zscaler Repo Server"
  security_group_id = aws_security_group.cc_mgmt_sg.id
  cidr_ipv4         = "167.103.95.222/32"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

resource "aws_vpc_security_group_egress_rule" "egress_cc_mgmt_udp_53" {
  description       = "CC Mgmt outbound DNS"
  security_group_id = aws_security_group.cc_mgmt_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}

resource "aws_vpc_security_group_egress_rule" "egress_cc_mgmt_tcp_12002" {
  description       = "CC Mgmt outbound Zscaler Remote Support TCP/12002"
  security_group_id = aws_security_group.cc_mgmt_sg.id
  cidr_ipv4         = var.zssupport_server
  from_port         = 12002
  ip_protocol       = "tcp"
  to_port           = 12002
}

################################################################################
# Create Security Group and Rules for Cloud Connector Service Interfaces
################################################################################
resource "aws_security_group" "cc_service_sg" {
  name        = "${var.name_prefix}-cc-svc-sg"
  description = "Security group for Cloud Connector service interfaces"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(var.tags,
    { Name = "${var.name_prefix}-cc-svc-sg" }
  )

  lifecycle {
    create_before_destroy = true
  }
}

#Default required ingress connectivity
resource "aws_vpc_security_group_ingress_rule" "ingress_cc_service_health_check" {
  description       = "CC Service TCP health probe"
  security_group_id = aws_security_group.cc_service_sg.id
  cidr_ipv4         = var.vpc_id
  from_port         = var.http_probe_port
  ip_protocol       = "tcp"
  to_port           = var.http_probe_port
}

resource "aws_vpc_security_group_ingress_rule" "ingress_cc_service_https_local" {
  description       = "CC inbound internal VPC cluster TCP 443 communication"
  security_group_id = aws_security_group.cc_service_sg.id
  cidr_ipv4         = var.vpc_id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

#Default required egress connectivity
resource "aws_vpc_security_group_egress_rule" "egress_cc_service_tcp_443" {
  description       = "CC outbound TCP 443"
  security_group_id = aws_security_group.cc_service_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_cc_service_udp_443" {
  description       = "CC Service outbound UDP 443"
  security_group_id = aws_security_group.cc_service_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "udp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_cc_service_udp_123" {
  description       = "CC Service outbound NTP"
  security_group_id = aws_security_group.cc_service_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 123
  ip_protocol       = "udp"
  to_port           = 123
}

resource "aws_vpc_security_group_egress_rule" "egress_cc_service_udp_53" {
  description       = "CC Service outbound DNS"
  security_group_id = aws_security_group.cc_service_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}

#Default required for GWLB deployments
resource "aws_vpc_security_group_ingress_rule" "ingress_cc_service_geneve" {
  description       = "CC GENEVE encapsulation traffic to CC Service from GWLB"
  security_group_id = aws_security_group.cc_service_sg.id
  cidr_ipv4         = var.vpc_id
  from_port         = 6081
  ip_protocol       = "udp"
  to_port           = 6081
}

resource "aws_vpc_security_group_egress_rule" "egress_cc_service_geneve" {
  description       = "CC GENEVE encapsulation traffic to GWLB from CC Service"
  security_group_id = aws_security_group.cc_service_sg.id
  cidr_ipv4         = var.vpc_id
  from_port         = 6081
  ip_protocol       = "udp"
  to_port           = 6081
}

#Default recommended egress connectivity. *Only required if sending direct/bypass non-https traffic through Cloud Connector
resource "aws_vpc_security_group_egress_rule" "egress_cc_service_all" {
  description       = "CC outbound all ports and protocols"
  security_group_id = aws_security_group.cc_service_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
