variable "subdomain" {
  type = string
}

variable "parent_zone_id" {
  type = string
}

resource "aws_route53_zone" "subdomain" {
  name = var.subdomain
}

resource "aws_route53_record" "subdomain" {
  zone_id = var.parent_zone_id
  name    = var.subdomain
  type    = "NS"
  ttl     = 172800
  records = aws_route53_zone.subdomain.name_servers
}
