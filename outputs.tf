# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/modules/#standard-module-structure

output "crossbarfx_dns_name" {
    value = aws_lb.crossbarfx-nlb.dns_name
}


output "crossbarfx_master_public_ip" {
    value = aws_instance.crossbarfx_node_master.public_ip
}


output "crossbarfx_master_private_ip" {
    value = aws_instance.crossbarfx_node_master.private_ip
}
