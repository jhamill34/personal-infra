//
// Assuming we've created the VPC already, this module creates a public subnet in the VPC
// and a private subnet. To distinguish the public subnet with the private subnet we 
// require a route table id that is has a route to the internet gateway. This structure 
// allows us to reuse a single internet gateway for multiple subnets.
//

resource "aws_subnet" "public" {
  vpc_id = var.vpc_id

  cidr_block        = var.public_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = var.public_route_table_id
}

// NOTE: the appeal to a private subnet is clear
// and if our hosts didn't need to access the internet this would be great!
// however, our hosts need to talk to ECS (we could technically use a VPC endpoint) and 
// in general we want to be able to access the internet for updates, etc. 
// to accomplish this we need to use a NAT Gateway which is far to costly for this example (~ $32.00/month)

resource "aws_subnet" "private" {
  vpc_id = var.vpc_id

  cidr_block        = var.private_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.name}-private"
  }
}

