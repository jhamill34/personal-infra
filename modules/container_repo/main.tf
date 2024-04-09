// Create an ECR repository
// this module isn't really needed but it used so that 
// we have the ability to add more configuration later

resource "aws_ecr_repository" "repository" {
  name = var.name
}
