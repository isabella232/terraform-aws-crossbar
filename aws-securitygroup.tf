# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "crossbar_cluster_node" {
    vpc_id      = aws_vpc.crossbar_vpc.id
    name        = "crossbar_cluster_node"
    description = "security group for edge nodes"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.crossbar_elb.id]
    }
    ingress {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        security_groups = [aws_security_group.crossbar_elb.id]
    }

    tags = {
        Name = "Crossbar.io Cloud (${var.dns-domain-name})"
        env = var.env
    }
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "crossbar_master_node" {
    vpc_id      = aws_vpc.crossbar_vpc.id
    name        = "crossbar_master_node"
    description = "security group for master nodes"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port       = 9000
        to_port         = 9000
        protocol        = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Crossbar.io Cloud (${var.dns-domain-name})"
        env = var.env
    }
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "crossbar_elb" {
    vpc_id      = aws_vpc.crossbar_vpc.id
    name        = "crossbar_elb"
    description = "security group for load balancer"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Crossbar.io Cloud (${var.dns-domain-name})"
        env = var.env
    }
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "crossbar_efs" {
    name = "crossbar_efs"
    vpc_id = aws_vpc.crossbar_vpc.id

    // NFS
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
    }

    // Terraform removes the default rule
    egress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 0
        protocol = "-1"
    }

    tags = {
        Name = "Crossbar.io Cloud (${var.dns-domain-name})"
        env = var.env
    }
}
