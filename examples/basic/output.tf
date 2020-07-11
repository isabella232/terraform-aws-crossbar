output "web-url" {
    value = module.crossbar.web-url
}

output "application-url" {
    value = module.crossbar.application-url
}

output "management-url" {
    value = module.crossbar.management-url
}

output "master-node" {
    value = module.crossbar.crossbar_master_public_dns
}
