# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/modules/#standard-module-structure

output "crossbar_dns_name" {
    value = aws_lb.crossbar-nlb1.dns_name
    description = "Public DNS name of main cluster endpoint (load-balancers pointing to Crossbar.io FX cluster nodes)."
}

output "crossbar_master_public_ip" {
    value = aws_instance.crossbar-master-node.public_ip
    description = "Public IP address of Crossbar.io FX master node."
}

output "crossbar_master_private_ip" {
    value = aws_instance.crossbar-master-node.private_ip
    description = "Private IP address of Crossbar.io FX master node."
}

output "crossbar_master_public_dns" {
    value = aws_route53_record.crossbar-master.name
    description = "Public DNS name of Crossbar.io FX master node."
}

output "management-url" {
    value = "ws://${aws_route53_record.crossbar-master.name}:9000/ws"
    description = "WAMP Management Transport URL (for management client connecting to the master node)."
}

output "application-url" {
    value = "wss://${aws_route53_record.crossbar-data.name}/ws"
    description = "WAMP Application Transport URL (for application clients connecting to the cluster)."
}

output "web-url" {
    value = "https://${aws_route53_record.crossbar-web-alias.name}"
    description = "Web URL (for application clients fetching Web content)."
}
