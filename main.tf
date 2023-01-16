provider "aws" {
  region = "ap-northeast-2"
}
# Configure the AWS Provider
resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "terraform-vpc"
    User = "Terraform"
  }
}
# Create Web Public Subnet
resource "aws_subnet" "terraform-web-public-subnet-1" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-web-public-subnet-1"
    User = "Terraform"
  }
}
resource "aws_subnet" "terraform-web-public-subnet-2" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-web-public-subnet-2"
    User = "Terraform"
  }
}
# Create Application Public Subnet
resource "aws_subnet" "terraform-was-private-subnet-1" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "10.10.11.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "terraform-was-private-subnet-1"
    User = "Terraform"
  }
}
resource "aws_subnet" "terraform-was-private-subnet-2" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "10.10.12.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = false
  tags = {
    Name = "terraform-was-private-subnet-2"
    User = "Terraform"
  }
}
# Create Database Private Subnet
resource "aws_subnet" "terraform-db-private-subnet-1" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "10.10.21.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "terraform-db-private-subnet-1"
    User = "Terraform"
  }
}
resource "aws_subnet" "terraform-db-private-subnet-2" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "10.10.22.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "terraform-db-private-subnet-2"
    User = "Terraform"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "terraform-internet-gateway" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = "terraform-internet-gateway"
    User = "Terraform"
  }
}
# Create Web layber route table
resource "aws_route_table" "terraform-web-routing" {
  vpc_id = aws_vpc.terraform-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-internet-gateway.id
  }
  tags = {
    Name = "terraform-web-routing"
    User = "Terraform"
  }
}
# Create Web Subnet association with Web route table
resource "aws_route_table_association" "association-route-table-1" {
  subnet_id      = aws_subnet.terraform-web-public-subnet-1.id
  route_table_id = aws_route_table.terraform-web-routing.id
}
resource "aws_route_table_association" "association-route-table-2" {
  subnet_id      = aws_subnet.terraform-web-public-subnet-2.id
  route_table_id = aws_route_table.terraform-web-routing.id
}
#Create EC2 Instance
resource "aws_instance" "terraform-web-server" {
  ami                    = "ami-0f2c95e9fe3f8f80e"
  instance_type          = "t2.micro"
  availability_zone      = "ap-northeast-2a"
  vpc_security_group_ids = [aws_security_group.terraform-web-sg.id]
  subnet_id              = aws_subnet.terraform-web-public-subnet-1.id
  key_name = "terraform-key"
  tags = {
    Name = "terraform-web-server"
    User = "Terraform"
  }
}
# Create Web Security Group
resource "aws_security_group" "terraform-web-sg" {
  name        = "terraform-web-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.terraform-vpc.id
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-web-sg"
    User = "Terraform"
  }
}
