# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# crossbar_vpc_master
# crossbar_vpc_efs1
# crossbar_vpc_efs2
# crossbar_vpc_efs3
# crossbar_vpc_public1
# crossbar_vpc_public2
# crossbar_vpc_public3
# crossbar_vpc_router1
# crossbar_vpc_router2
# crossbar_vpc_router3

# https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "crossbar_vpc" {
    cidr_block           = "${var.cidr-prefix}0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = "true"
    enable_dns_hostnames = "true"
    enable_classiclink   = "false"

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}


# https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "crossbar_vpc_master" {
    vpc_id                              = aws_vpc.crossbar_vpc.id
    cidr_block                          = "${var.cidr-prefix}10.0/24"
    map_public_ip_on_launch             = "true"
    availability_zone                   = var.aws-azs[var.aws-region][0]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

resource "aws_subnet" "crossbar_vpc_efs1" {
    vpc_id                  = aws_vpc.crossbar_vpc.id
    cidr_block              = "${var.cidr-prefix}11.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.aws-azs[var.aws-region][0]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

resource "aws_subnet" "crossbar_vpc_efs2" {
    vpc_id                  = aws_vpc.crossbar_vpc.id
    cidr_block              = "${var.cidr-prefix}12.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.aws-azs[var.aws-region][1]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

resource "aws_subnet" "crossbar_vpc_efs3" {
    vpc_id                  = aws_vpc.crossbar_vpc.id
    cidr_block              = "${var.cidr-prefix}13.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.aws-azs[var.aws-region][2]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

resource "aws_subnet" "crossbar_vpc_public1" {
    vpc_id                              = aws_vpc.crossbar_vpc.id
    cidr_block                          = "${var.cidr-prefix}1.0/24"
    map_public_ip_on_launch             = "true"
    availability_zone                   = var.aws-azs[var.aws-region][0]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

resource "aws_subnet" "crossbar_vpc_public2" {
    vpc_id                              = aws_vpc.crossbar_vpc.id
    cidr_block                          = "${var.cidr-prefix}2.0/24"
    map_public_ip_on_launch             = "true"
    availability_zone                   = var.aws-azs[var.aws-region][1]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

resource "aws_subnet" "crossbar_vpc_public3" {
    vpc_id                              = aws_vpc.crossbar_vpc.id
    cidr_block                          = "${var.cidr-prefix}3.0/24"
    map_public_ip_on_launch             = "true"
    availability_zone                   = var.aws-azs[var.aws-region][2]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

resource "aws_subnet" "crossbar_vpc_router1" {
    vpc_id                  = aws_vpc.crossbar_vpc.id
    cidr_block              = "${var.cidr-prefix}4.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = var.aws-azs[var.aws-region][0]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

resource "aws_subnet" "crossbar_vpc_router2" {
    vpc_id                  = aws_vpc.crossbar_vpc.id
    cidr_block              = "${var.cidr-prefix}5.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = var.aws-azs[var.aws-region][1]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

resource "aws_subnet" "crossbar_vpc_router3" {
    vpc_id                  = aws_vpc.crossbar_vpc.id
    cidr_block              = "${var.cidr-prefix}6.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = var.aws-azs[var.aws-region][2]

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}


# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "crossbar_vpc_gw" {
    vpc_id = aws_vpc.crossbar_vpc.id

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}


# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "crossbar_vpc_rtb" {
    vpc_id = aws_vpc.crossbar_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.crossbar_vpc_gw.id
    }

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}


# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "crossbar_vpc_master" {
    subnet_id      = aws_subnet.crossbar_vpc_master.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}

resource "aws_route_table_association" "crossbar_vpc-public-1-a" {
    subnet_id      = aws_subnet.crossbar_vpc_public1.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}

resource "aws_route_table_association" "crossbar_vpc-public-2-a" {
    subnet_id      = aws_subnet.crossbar_vpc_public2.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}

resource "aws_route_table_association" "crossbar_vpc-public-3-a" {
    subnet_id      = aws_subnet.crossbar_vpc_public3.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}

resource "aws_route_table_association" "crossbar_vpc-router-1-a" {
    subnet_id      = aws_subnet.crossbar_vpc_router1.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}

resource "aws_route_table_association" "crossbar_vpc-router-2-a" {
    subnet_id      = aws_subnet.crossbar_vpc_router2.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}

resource "aws_route_table_association" "crossbar_vpc-router-3-a" {
    subnet_id      = aws_subnet.crossbar_vpc_router3.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}

resource "aws_route_table_association" "crossbar_vpc-efs-1-a" {
    subnet_id      = aws_subnet.crossbar_vpc_efs1.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}

resource "aws_route_table_association" "crossbar_vpc-efs-2-a" {
    subnet_id      = aws_subnet.crossbar_vpc_efs2.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}

resource "aws_route_table_association" "crossbar_vpc-efs-3-a" {
    subnet_id      = aws_subnet.crossbar_vpc_efs3.id
    route_table_id = aws_route_table.crossbar_vpc_rtb.id
}
