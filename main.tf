terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.35.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA4IIAMLFXLBBJT3UI"
  secret_key = "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"
}  


# Create a VPC
resource "aws_vpc" "myapp_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "app-vpc"
  }
}

# Create a aws internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myapp_vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

# Create a aws subnet 
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.myapp_vpc.id
  cidr_block        = "172.16.10.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

# Create a aws subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_instance" "web" {
  ami             = "ami-08c40ec9ead489470" 
  instance_type   = "t2.micro"
  key_name        = "mykey"
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]

  user_data = "${file("install_apache.sh")}"

#   user_data = <<-EOF
#   #!/bin/bash
#   echo "*** Installing apache2"
#   sudo apt update -y
#   sudo apt install apache2 -y
#   echo "*** Completed Installing apache2"
#   EOF

  tags = {
    Name = "web_instance"
  }

  volume_tags = {
    Name = "web_instance"
  } 
}



