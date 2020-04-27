provider "aws" {
    region = "eu-west-1"
}

# Create a VPC
resource "aws_vpc" "app_vpc" {
   cidr_block = "10.0.0.0/16"
   tags = {
       Name = "${var.name}-eng54-app_vpc"
   }
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


module "app" {
  source = "./modules/app_tier"
  vpc_id = var.vpc_id
  name = var.name
  ami_id = var.ami_id
  gateway_id = data.aws_internet_gateway.default-gw.id
}
