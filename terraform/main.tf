resource "aws_key_pair" "terra-key" {
  key_name   = "terra-key"
  public_key = file("terra-key.pub")
}

# VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "myvpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

# Public Subnet 1 (AZ: us-east-2a)
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

# Public Subnet 2 (AZ: us-east-2b)
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate Subnet 1
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

# Associate Subnet 2
resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}


# Security Group for Jenkins
resource "aws_security_group" "Jenkins-sg" {
  name        = "Jenkins-sg"
  description = "allow http, https, ssh and port 8080"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "Jenkins-sg"
  }
}

# Security Group for Kubernetes (open for installation only)
resource "aws_security_group" "K8s-sg" {
  name        = "K8s-sg"
  description = "allow all traffic for now till installation"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "K8s-sg"
  }
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins_ec2" {
  ami                    = "ami-04f167a56786e4b09"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terra-key.key_name
  subnet_id            = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
  associate_public_ip_address = true

  depends_on = [
    aws_security_group.Jenkins-sg,
  ]

  tags = {
    Name = "jenkins-ec2"
  }
}

# Kubernetes EC2 Instances (3 nodes)
resource "aws_instance" "K8s_ec2" {
  count                  = 3
  ami                    = "ami-04f167a56786e4b09"
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.terra-key.key_name
  subnet_id = element([aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id], count.index % 2)
  vpc_security_group_ids = [aws_security_group.K8s-sg.id]
  associate_public_ip_address = true

  depends_on = [
    aws_security_group.K8s-sg
  ]

  tags = {
    Name = "k8s-node-${count.index + 1}"
  }
}
