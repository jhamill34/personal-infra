variable "parent_zone_id" {
  description = "The ID of the parent zone"
  type        = string
}

module "blog_jhamill_tech_domain" {
  source         = "../../modules/subdomain"
  parent_zone_id = var.parent_zone_id
  subdomain      = "blog.jhamill.tech"
}

module "blog_jhamill_tech_site" {
  source  = "../../modules/static_site"
  name    = "blog-jhamill-tech-website"
  domain  = "blog.jhamill.tech"
  zone_id = module.blog_jhamill_tech_domain.zone_id
}
