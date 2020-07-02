# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# crossbarfx_vpc_efs
# crossbarfx_vpc_master
# crossbarfx_vpc_public1
# crossbarfx_vpc_public2
# crossbarfx_vpc_public3
# crossbarfx_vpc_router1
# crossbarfx_vpc_router2
# crossbarfx_vpc_router3

# https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "crossbarfx_vpc" {
    cidr_block           = "10.0.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = "true"
    enable_dns_hostnames = "true"
    enable_classiclink   = "false"
    tags = {
        Name = "crossbarfx_vpc"
    }
}

# https://www.terraform.io/docs/providers/aws/r/subnet.html

resource "aws_subnet" "crossbarfx_vpc_master" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.10.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.AWS_AZ[0]

    tags = {
        Name = "crossbarfx_vpc_master"
    }
}

resource "aws_subnet" "crossbarfx_vpc_efs1" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.11.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.AWS_AZ[0]

    tags = {
        Name = "crossbarfx_vpc_efs1"
    }
}

resource "aws_subnet" "crossbarfx_vpc_efs2" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.12.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.AWS_AZ[0]

    tags = {
        Name = "crossbarfx_vpc_efs2"
    }
}

resource "aws_subnet" "crossbarfx_vpc_efs3" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.13.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.AWS_AZ[0]

    tags = {
        Name = "crossbarfx_vpc_efs3"
    }
}

resource "aws_subnet" "crossbarfx_vpc_public1" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.AWS_AZ[0]

    tags = {
        Name = "crossbarfx_vpc_public1"
    }
}

resource "aws_subnet" "crossbarfx_vpc_public2" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.AWS_AZ[1]

    tags = {
        Name = "crossbarfx_vpc_public2"
    }
}

resource "aws_subnet" "crossbarfx_vpc_public3" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.AWS_AZ[2]

    tags = {
        Name = "crossbarfx_vpc_public3"
    }
}

resource "aws_subnet" "crossbarfx_vpc_router1" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.4.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = var.AWS_AZ[0]

    tags = {
        Name = "crossbarfx_vpc_router1"
    }
}

resource "aws_subnet" "crossbarfx_vpc_router2" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.5.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = var.AWS_AZ[1]

    tags = {
        Name = "crossbarfx_vpc_router2"
    }
}

resource "aws_subnet" "crossbarfx_vpc_router3" {
    vpc_id                  = aws_vpc.crossbarfx_vpc.id
    cidr_block              = "10.0.6.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = var.AWS_AZ[2]

    tags = {
        Name = "crossbarfx_vpc_router3"
    }
}

# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "crossbarfx_vpc_gw" {
    vpc_id = aws_vpc.crossbarfx_vpc.id

    tags = {
        Name = "crossbarfx_vpc_gw"
    }
}

# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "crossbarfx_vpc_public" {
    vpc_id = aws_vpc.crossbarfx_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.crossbarfx_vpc_gw.id
    }

    tags = {
        Name = "crossbarfx_vpc_public"
    }
}

# route associations public
resource "aws_route_table_association" "crossbarfx_vpc_master" {
    subnet_id      = aws_subnet.crossbarfx_vpc_master.id
    route_table_id = aws_route_table.crossbarfx_vpc_public.id
}

# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "crossbarfx_vpc-public-1-a" {
    subnet_id      = aws_subnet.crossbarfx_vpc_public1.id
    route_table_id = aws_route_table.crossbarfx_vpc_public.id
}

resource "aws_route_table_association" "crossbarfx_vpc-public-2-a" {
    subnet_id      = aws_subnet.crossbarfx_vpc_public2.id
    route_table_id = aws_route_table.crossbarfx_vpc_public.id
}

resource "aws_route_table_association" "crossbarfx_vpc-public-3-a" {
    subnet_id      = aws_subnet.crossbarfx_vpc_public3.id
    route_table_id = aws_route_table.crossbarfx_vpc_public.id
}
