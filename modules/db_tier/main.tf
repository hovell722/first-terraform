

resource "aws_subnet" "db_subnet" {
    vpc_id = var.vpc_id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-west-1a"
    tags = {
      Name = "${var.name}-private"
    }
}

resource "aws_network_acl" "app_network_acl" {
  vpc_id = var.vpc_id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 27107
    to_port    = 27107
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.name}-nacl-private"
  }
}

resource "aws_security_group" "app_sg" {
    name = "eng54-James-sg-db"
    description = "security group that allows port 80 from anywhere"
    vpc_id      = var.vpc_id


  ingress {
    description = "Allows port 27107"
    from_port   = 27107
    to_port     = 27107
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    description = "Allows port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-tags-private"
  }
}
