resource "aws_security_group" "loadbalancer" {
  vpc_id = var.vpc_id
  name   = "${var.name_prefix}-loadbalancer-sg"

  tags = {
    Name = "${var.name_prefix}-loadbalancer-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "loadbalancer_http" {
  description       = "Allow HTTP inbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.loadbalancer.id
}

resource "aws_vpc_security_group_egress_rule" "loadbalancer_http" {
  description                  = "Pass HTTP Traffic to webservers"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  security_group_id            = aws_security_group.loadbalancer.id
  referenced_security_group_id = aws_security_group.webserver.id
}

resource "aws_vpc_security_group_ingress_rule" "loadbalancer_https" {
  description       = "Allow HTTPS inbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.loadbalancer.id
}

resource "aws_vpc_security_group_egress_rule" "loadbalancer_https" {
  description                  = "Pass HTTPS Traffic to webservers"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  security_group_id            = aws_security_group.loadbalancer.id
  referenced_security_group_id = aws_security_group.webserver.id
}


resource "aws_security_group" "webserver" {
  vpc_id = var.vpc_id
  name   = "${var.name_prefix}-webserver-sg"

  tags = {
    Name = "${var.name_prefix}-webserver-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "webserver_http" {
  description       = "Allow HTTP inbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.webserver.id
}

resource "aws_vpc_security_group_ingress_rule" "webserver_ssh" {
  description       = "Allow HTTP inbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  security_group_id = aws_security_group.webserver.id
}

resource "aws_vpc_security_group_egress_rule" "webserver_http" {
  description       = "Allow HTTP inbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.webserver.id
}

resource "aws_vpc_security_group_ingress_rule" "webserver_https" {
  description       = "Allow HTTPS inbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.webserver.id
}

resource "aws_vpc_security_group_egress_rule" "webserver_https" {
  description       = "Allow HTTPS inbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.webserver.id
}

resource "aws_security_group" "database" {
  vpc_id = var.vpc_id
  name   = "${var.name_prefix}-database-sg"

  tags = {
    Name = "${var.name_prefix}-database-sg"
  }
}

