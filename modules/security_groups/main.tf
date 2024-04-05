resource "aws_security_group" "load_balancer" {
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
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_ingress_rule" "loadbalancer_https" {
  description       = "Allow HTTPS inbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_egress_rule" "loadbalancer_all" {
  description                  = "Allow all outbound traffic"
  ip_protocol                  = "tcp"
  from_port                    = 0
  to_port                      = 65535
  security_group_id            = aws_security_group.load_balancer.id
  referenced_security_group_id = aws_security_group.webserver.id
}


resource "aws_security_group" "webserver" {
  vpc_id = var.vpc_id
  name   = "${var.name_prefix}-webserver-sg"

  tags = {
    Name = "${var.name_prefix}-webserver-sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "webserver_https" {
  description                  = "Allow HTTPS inbound traffic"
  ip_protocol                  = "tcp"
  from_port                    = 0
  to_port                      = 65535
  security_group_id            = aws_security_group.webserver.id
  referenced_security_group_id = aws_security_group.load_balancer.id
}

resource "aws_vpc_security_group_egress_rule" "webserver_all" {
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 0
  to_port           = 65535
  security_group_id = aws_security_group.webserver.id
}

// resource "aws_security_group" "database" {
//   vpc_id = var.vpc_id
//   name   = "${var.name_prefix}-database-sg"
//   tags = {
//     Name = "${var.name_prefix}-database-sg"
//   }
// }
// 
