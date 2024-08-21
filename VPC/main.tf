terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

############# terraform cloud #######################

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Terraform_Infra_Automation"

    workspaces {
      name = "Kubernetes-VPC-workspace"
    }
  }
}


###########################     VPC      #############################################
resource "aws_vpc" "TF_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name        = "Dev-VPC"
    Environment = var.Environment
  }
}




################################## Public Subnets  ##############################################
resource "aws_subnet" "pub_sub-1" {
  vpc_id                  = aws_vpc.TF_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone-1

  tags = {
    Name        = "public_sub-1"
    Environment = var.Environment
  }
}


resource "aws_subnet" "pub_sub-2" {
  vpc_id                  = aws_vpc.TF_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone-2

  tags = {
    Name        = "public_sub-2"
    Environment = var.Environment
  }
}


############################## Security group  for public Instance###################################################
resource "aws_security_group" "TF_sec" {
  name        = "demo_sec"
  description = "allow TLS inbound traffic"
  vpc_id      = aws_vpc.TF_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.TF_vpc.cidr_block]
  }

  ingress {
    description = "ALL traffic allowed"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.TF_vpc.cidr_block]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.TF_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "Tesing_security_group"
    Environment = var.Environment
  }
}




###################################### Internet Gateway ########################################################

resource "aws_internet_gateway" "TF_IGW" {
  vpc_id = aws_vpc.TF_vpc.id
  tags = {
    Name = "TF_IG"
  }
}


######################################### Route Table #############################################################

resource "aws_route_table" "TF_public_RT" {
  vpc_id = aws_vpc.TF_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TF_IGW.id
  }
  tags = {
    Name = "TF_public_RT"
  }
}

########################################### Route table association #########################################################

resource "aws_route_table_association" "TF_RT_association" {
  subnet_id      = aws_subnet.pub_sub-1.id
  route_table_id = aws_route_table.TF_public_RT.id

}


# ########################################## Elastic IP for the NAT Gateway ###########################

resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.TF_RT_association
  ]

  domain = "vpc"
}

resource "aws_nat_gateway" "TF_NAT" {

  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  subnet_id     = aws_subnet.pub_sub-1.id
  tags = {
    Name = "nat-gateway"
  }
}

# ################################################### NAT Route Table ################################################################

resource "aws_route_table" "TF_routeTable-2" {

  depends_on = [
    aws_nat_gateway.TF_NAT
  ]

  vpc_id = aws_vpc.TF_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.TF_NAT.id
  }
  tags = {
    Name        = "TF_routeTable-2"
    description = "Route table of NAT Gate way "
  }
}

# ################################################ NAT Route table association ####################################################

resource "aws_route_table_association" "TF_NAT_RT_Association" {
  depends_on = [
    aws_route_table.TF_routeTable-2
  ]
  subnet_id = aws_subnet.pub_sub-2.id
  # subnet_id      = data.terraform_remote_state.SG.outputs.subnet_id ### calling this from security group workspace ##########
  route_table_id = aws_route_table.TF_routeTable-2.id
}


