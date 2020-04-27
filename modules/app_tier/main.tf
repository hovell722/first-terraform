# App tier
# move here anything to do with the app tier creation

# Creating public subnet
resource "aws_subnet" "app_subnet" {
    vpc_id = var.vpc_id
    cidr_block = "172.31.93.0/24"
    availability_zone = "eu-west-1a"
    tags = {
      Name = var.name
    }
}

# Creating route table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }

  tags = {
    Name = "${var.name}-public"
  }
}

# Creating route table associations
resource "aws_route_table_association" "assoc" {
  subnet_id = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.public.id
}

# Creating template script
data "template_file" "app_init" {
  template = file("./scripts/app/init.sh.tpl")
# .tpl like .erb allows us to interpolate variables into static templates
  # making them dynamic
  vars = {
    my_name = "${var.name} is the real name James"
  }
  # setting ports
  # for the mongod db, seting private_ip for db_host
  # AWS gives us new Ips - if we want to make one machine aware of another this could be useful
}

# Adding security groups
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
}
