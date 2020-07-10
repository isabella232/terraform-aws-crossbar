# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/modules/#standard-module-structure

output "crossbar_dns_name" {
    value = aws_lb.crossbar-nlb.dns_name
    description = "Public DNS name of main cluster endpoint (load-balancers pointing to Crossbar.io FX cluster nodes)."
}

output "crossbar_master_public_ip" {
    value = aws_instance.crossbar_node_master[0].public_ip
    description = "Public IP address of Crossbar.io FX master node."
}

output "crossbar_master_private_ip" {
    value = aws_instance.crossbar_node_master[0].private_ip
    description = "Private IP address of Crossbar.io FX master node."
}

# output "crossbar_master_public_dns" {
#     value = aws_route53_record.crossbar-master[0].name
#     description = "Public DNS name of Crossbar.io FX master node."
# }
