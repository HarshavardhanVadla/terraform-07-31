#Create VPC
resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}

#Create Internet gateway and attach vpc
resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "dev-igw"
  }
}

#Create Public Subnet
resource "aws_subnet" "dev" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "dev-public-subnet"
  }
}

#Create Private subnet
#resource "aws_subnet" "dev1" {
# vpc_id = aws_vpc.dev1.id
#cidr_block = "10.0.2.0/24"
#availability_zone = "ap-northeast-1a"
#map_public_ip_on_launch = false
#tags = {
# Name = "dev1-private-subnet"
#}
#}

#Create route table and associate internet gateway and subnet
resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "dev-route-table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }
}
resource "aws_route_table_association" "dev" {
  subnet_id      = aws_subnet.dev.id
  route_table_id = aws_route_table.dev.id
}

#Create security group and attach to vpc
resource "aws_security_group" "dev" {
  vpc_id      = aws_vpc.dev.id
  name        = "allow_traffic"
  description = "Allow TLS inbound traffic and all outbound traffic"
  tags = {
    Name = "dev-sg"
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create Key pair

#Create Instance
resource "aws_instance" "dev" {
  ami                         = "ami-0d03c6e00d5732e28"
  instance_type               = "t2.micro"
  key_name                    = "Terra-Key-Pair"
  vpc_security_group_ids      = [aws_security_group.dev.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.dev.id
  availability_zone           = "ap-northeast-1a"
  tags = {
    Name = "Harsha1"
  }
}
# Creating s3 bucket along dynamodb lock
resource "aws_s3_bucket" "test" {
  bucket = "s3h2"

}
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
