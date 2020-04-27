provider "aws" {
    region = "eu-west-1"
}

# Create a VPC
#resource "aws_vpc" "app_vpc" {
#    cidr_block = "10.0.0.0/16"
#    tags = {
#        Name = "James-eng54-app_vpc"
#    }
#}

# use our devops vpcc
  # vpc-07e47e9d90d2076da
# create new subnet
# move our instance into said subnet
resource "aws_subnet" "app_subnet" {
    vpc_id = var.vpc_id
    cidr_block = "172.31.93.0/24"
    availability_zone = "eu-west-1a"
    tags = {
      Name = var.name
    }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default-gw.id
  }

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.public.id
}

# we don't need a new internet gateway -
# we can query our existing vpc/infrastructure with the 'data' handler/function
data "aws_internet_gateway" "default-gw" {
  filter {
    # on the hashicorp docs, it references AWS-API thath has this filter "attachment.vpc-id"
    name = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}


resource "aws_security_group" "app_sg" {
    name = "eng54-James-sg"
    description = "security group that allows port 80 from anywhere"
    vpc_id      = var.vpc_id

  ingress {
    description = "Allows port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allows port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allows port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["90.193.220.135/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-tags"
  }
}

data "template_file" "app_init" {
  template = file("./scripts/app/init.sh.tpl")
}

# Launching an instance
resource "aws_instance" "app_instance" {
    ami = var.ami_id
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = aws_subnet.app_subnet.id
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    tags = {
        Name = var.name
    }
    key_name = "james-eng54"

    user_data = data.template_file.app_init.rendered

  # provisioner "remote-exec" {
  #   inline = [
  #     "cd /home/ubuntu/app",
  #     "npm start"
  #   ]
  # }
  # connection {
  #   type     = "ssh"
  #   user     = "ubuntu"
  #   host = self.public_ip
  #   private_key = file("~/.ssh/james-eng54.pem")
  # }

}
