# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# crossbar-vpc1-master
# crossbar-vpc1-efs1
# crossbar-vpc1-efs2
# crossbar-vpc1-efs3
# crossbar-vpc1-public1
# crossbar-vpc1-public2
# crossbar-vpc1-public3
# crossbar-vpc1-router1
# crossbar-vpc1-router2
# crossbar-vpc1-router3

# https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "crossbar-vpc1" {
    cidr_block           = "${var.cidr-prefix}0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = "true"
    enable_dns_hostnames = "true"
    enable_classiclink   = "false"

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}


# https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "crossbar-vpc1-master" {
    vpc_id                              = aws_vpc.crossbar-vpc1.id
    cidr_block                          = "${var.cidr-prefix}10.0/24"
    map_public_ip_on_launch             = "true"
    availability_zone                   = var.aws-azs[var.aws-region][0]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_subnet" "crossbar-vpc1-efs1" {
    vpc_id                  = aws_vpc.crossbar-vpc1.id
    cidr_block              = "${var.cidr-prefix}11.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.aws-azs[var.aws-region][0]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_subnet" "crossbar-vpc1-efs2" {
    vpc_id                  = aws_vpc.crossbar-vpc1.id
    cidr_block              = "${var.cidr-prefix}12.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.aws-azs[var.aws-region][1]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_subnet" "crossbar-vpc1-efs3" {
    vpc_id                  = aws_vpc.crossbar-vpc1.id
    cidr_block              = "${var.cidr-prefix}13.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.aws-azs[var.aws-region][2]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_subnet" "crossbar-vpc1-public1" {
    vpc_id                              = aws_vpc.crossbar-vpc1.id
    cidr_block                          = "${var.cidr-prefix}1.0/24"
    map_public_ip_on_launch             = "true"
    availability_zone                   = var.aws-azs[var.aws-region][0]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_subnet" "crossbar-vpc1-public2" {
    vpc_id                              = aws_vpc.crossbar-vpc1.id
    cidr_block                          = "${var.cidr-prefix}2.0/24"
    map_public_ip_on_launch             = "true"
    availability_zone                   = var.aws-azs[var.aws-region][1]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_subnet" "crossbar-vpc1-public3" {
    vpc_id                              = aws_vpc.crossbar-vpc1.id
    cidr_block                          = "${var.cidr-prefix}3.0/24"
    map_public_ip_on_launch             = "true"
    availability_zone                   = var.aws-azs[var.aws-region][2]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_subnet" "crossbar-vpc1-router1" {
    vpc_id                  = aws_vpc.crossbar-vpc1.id
    cidr_block              = "${var.cidr-prefix}4.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = var.aws-azs[var.aws-region][0]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_subnet" "crossbar-vpc1-router2" {
    vpc_id                  = aws_vpc.crossbar-vpc1.id
    cidr_block              = "${var.cidr-prefix}5.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = var.aws-azs[var.aws-region][1]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_subnet" "crossbar-vpc1-router3" {
    vpc_id                  = aws_vpc.crossbar-vpc1.id
    cidr_block              = "${var.cidr-prefix}6.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = var.aws-azs[var.aws-region][2]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}


# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "crossbar-vpc1-gw" {
    vpc_id = aws_vpc.crossbar-vpc1.id

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}


# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "crossbar-vpc1-rtb1" {
    vpc_id = aws_vpc.crossbar-vpc1.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.crossbar-vpc1-gw.id
    }

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}


# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "crossbar-vpc1-master" {
    subnet_id      = aws_subnet.crossbar-vpc1-master.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}

resource "aws_route_table_association" "crossbar-vpc1-public1" {
    subnet_id      = aws_subnet.crossbar-vpc1-public1.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}

resource "aws_route_table_association" "crossbar-vpc1-public2" {
    subnet_id      = aws_subnet.crossbar-vpc1-public2.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}

resource "aws_route_table_association" "crossbar-vpc1-public3" {
    subnet_id      = aws_subnet.crossbar-vpc1-public3.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}

resource "aws_route_table_association" "crossbar-vpc1-router1" {
    subnet_id      = aws_subnet.crossbar-vpc1-router1.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}

resource "aws_route_table_association" "crossbar-vpc1-router2" {
    subnet_id      = aws_subnet.crossbar-vpc1-router2.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}

resource "aws_route_table_association" "crossbar-vpc1-router3" {
    subnet_id      = aws_subnet.crossbar-vpc1-router3.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}

resource "aws_route_table_association" "crossbar-vpc1-efs1" {
    subnet_id      = aws_subnet.crossbar-vpc1-efs1.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}

resource "aws_route_table_association" "crossbar-vpc1-efs2" {
    subnet_id      = aws_subnet.crossbar-vpc1-efs2.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}

resource "aws_route_table_association" "crossbar-vpc1-efs3" {
    subnet_id      = aws_subnet.crossbar-vpc1-efs3.id
    route_table_id = aws_route_table.crossbar-vpc1-rtb1.id
}
