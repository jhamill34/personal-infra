
// NOTE: Be very careful with this file, changes here 
// can mean that we end up deleting a hosted zone and recreating it which 
// could change our nameservers

resource "aws_route53_zone" "spedue_com" {
  name = "spedue.com"
}

resource "aws_route53_zone" "spedue_space" {
  name = "spedue.space"
}

resource "aws_route53_zone" "jhamill_tech" {
  name = "jhamill.tech"
}

resource "aws_route53_zone" "amadahamill_art" {
  name = "amandahamill.art"
}

resource "aws_route53_zone" "orlandoartpost_com" {
  name = "orlandoartpost.com"
}

output "spedue_com" {
  value = aws_route53_zone.spedue_com
}

output "spedue_space" {
  value = aws_route53_zone.spedue_space
}

output "jhamill_tech" {
  value = aws_route53_zone.jhamill_tech
}

output "amandahamill_art" {
  value = aws_route53_zone.amadahamill_art
}

output "orlandoartpost_com" {
  value = aws_route53_zone.orlandoartpost_com
}
