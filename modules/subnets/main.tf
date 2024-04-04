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

resource "aws_subnet" "private" {
  vpc_id = var.vpc_id

  cidr_block        = var.private_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.name}-private"
  }
}

