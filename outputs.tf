# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/modules/#standard-module-structure

output "crossbar_dns_name" {
    value = aws_lb.crossbar-nlb.dns_name
}


output "crossbar_master_public_ip" {
    value = aws_instance.crossbar_node_master[0].public_ip
}


output "crossbar_master_private_ip" {
    value = aws_instance.crossbar_node_master[0].private_ip
}
