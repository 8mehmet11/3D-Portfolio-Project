provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "Project-Portfolio" {
  ami           = "ami-00beae93a2d981137"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.tf-PP-sg.name]
  key_name      = local_file.PPkey.filename   # write your pem file without .pem extension>
  user_data = "${file("userdata.sh")}"

  tags = {
    "Name" = "Project-Portfolio"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_key_pair" "PPkey" {
  key_name   = "PPkey"
  public_key = tls_private_key.PPrsa.public_key_openssh
}

resource "tls_private_key" "PPrsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "PPkey" {
  content  = tls_private_key.PPrsa.private_key_pem
  filename = "PPkey"
}

resource "aws_security_group" "tf-PP-sg" {
  name = "tf-PP-sg"
  description = "terraform Project security group"
  tags = {
    Name = "tf-PP-sg"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}