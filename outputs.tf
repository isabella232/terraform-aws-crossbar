# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/modules/#standard-module-structure

output "crossbarfx_dns_name" {
    value = aws_lb.crossbarfx-nlb.dns_name
}
