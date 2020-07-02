###############################################################################
#
# The MIT License (MIT)
#
# Copyright (c) Crossbar.io Technologies GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################


# https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "vpc1" {
    cidr_block           = "10.0.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = "true"
    enable_dns_hostnames = "true"
    enable_classiclink   = "false"
    tags = {
        Name = "vpc1"
    }
}

# https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "vpc1-master" {
    vpc_id                  = aws_vpc.vpc1.id
    cidr_block              = "10.0.10.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "eu-central-1a"

    tags = {
        Name = "vpc1-master"
    }
}

resource "aws_subnet" "vpc1-public-1" {
    vpc_id                  = aws_vpc.vpc1.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "eu-central-1a"

    tags = {
        Name = "vpc1-public-1"
    }
}

resource "aws_subnet" "vpc1-public-2" {
    vpc_id                  = aws_vpc.vpc1.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "eu-central-1b"

    tags = {
        Name = "vpc1-public-2"
    }
}

resource "aws_subnet" "vpc1-public-3" {
    vpc_id                  = aws_vpc.vpc1.id
    cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "eu-central-1c"

    tags = {
        Name = "vpc1-public-3"
    }
}

resource "aws_subnet" "vpc1-private-1" {
    vpc_id                  = aws_vpc.vpc1.id
    cidr_block              = "10.0.4.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = "eu-central-1a"

    tags = {
        Name = "vpc1-private-1"
    }
}

resource "aws_subnet" "vpc1-private-2" {
    vpc_id                  = aws_vpc.vpc1.id
    cidr_block              = "10.0.5.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = "eu-central-1b"

    tags = {
        Name = "vpc1-private-2"
    }
}

resource "aws_subnet" "vpc1-private-3" {
    vpc_id                  = aws_vpc.vpc1.id
    cidr_block              = "10.0.6.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = "eu-central-1c"

    tags = {
        Name = "vpc1-private-3"
    }
}

# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "vpc1-gw" {
    vpc_id = aws_vpc.vpc1.id

    tags = {
        Name = "vpc1"
    }
}

# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "vpc1-public" {
    vpc_id = aws_vpc.vpc1.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vpc1-gw.id
    }

    tags = {
        Name = "vpc1-public-1"
    }
}

# route associations public
resource "aws_route_table_association" "vpc1-master" {
    subnet_id      = aws_subnet.vpc1-master.id
    route_table_id = aws_route_table.vpc1-public.id
}

# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "vpc1-public-1-a" {
    subnet_id      = aws_subnet.vpc1-public-1.id
    route_table_id = aws_route_table.vpc1-public.id
}

resource "aws_route_table_association" "vpc1-public-2-a" {
    subnet_id      = aws_subnet.vpc1-public-2.id
    route_table_id = aws_route_table.vpc1-public.id
}

resource "aws_route_table_association" "vpc1-public-3-a" {
    subnet_id      = aws_subnet.vpc1-public-3.id
    route_table_id = aws_route_table.vpc1-public.id
}
