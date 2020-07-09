# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "crossbarfx_cluster_node" {
    vpc_id      = aws_vpc.crossbarfx_vpc.id
    name        = "crossbarfx_cluster_node"
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
        security_groups = [aws_security_group.crossbarfx_elb.id]
    }
    ingress {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        security_groups = [aws_security_group.crossbarfx_elb.id]
    }
    tags = {
        Name = "crossbarfx_cluster_node"
    }
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "crossbarfx_master_node" {
    vpc_id      = aws_vpc.crossbarfx_vpc.id
    name        = "crossbarfx_master_node"
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
        Name = "crossbarfx_master_node"
    }
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "crossbarfx_elb" {
    vpc_id      = aws_vpc.crossbarfx_vpc.id
    name        = "crossbarfx_elb"
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
        Name = "crossbarfx_elb"
    }
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "crossbarfx_efs" {
    name = "crossbarfx_efs"
    vpc_id = aws_vpc.crossbarfx_vpc.id

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
        Name = "crossbarfx_efs"
    }
}
