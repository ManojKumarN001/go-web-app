resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { "Name" = "${var.name_prefix}/VPC" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { "Name" = "${var.name_prefix}/InternetGateway" })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, {
    "Name" = "${var.name_prefix}/SubnetPublic${element(var.availability_zones, count.index)}"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags              = merge(var.tags, {
    "Name" = "${var.name_prefix}/SubnetPrivate${element(var.availability_zones, count.index)}"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  tags          = merge(var.tags, { "Name" = "${var.name_prefix}/NATGateway" })
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { "Name" = "${var.name_prefix}/PublicRouteTable" })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)  # Ensure that 'count' is used

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags, 
    { 
      "Name" = "${var.name_prefix}/PrivateRouteTable${element(var.availability_zones, count.index)}" 
    }
  )
}


# resource "aws_route" "private_nat_gateway" {
#   count = length([
#     for rt in aws_route_table.private : rt.id
#     if length([for r in rt.route : r if r.cidr_block != "0.0.0.0/0"]) > 0
#   ])

#   route_table_id         = aws_route_table.private[count.index].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.this[count.index].id
# }

data "aws_route_tables" "private" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }
}

locals {
  private_route_tables_with_routes = [
    for rt in data.aws_route_tables.private.ids : rt
    if length([
      for r in aws_route_table.private[rt].route : r
      if r.cidr_block != "0.0.0.0/0"
    ]) > 0
  ]
}

resource "aws_route" "private_nat_gateway" {
  count = length(local.private_route_tables_with_routes)

  route_table_id         = local.private_route_tables_with_routes[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}




