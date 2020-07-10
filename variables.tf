# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

variable "env" {
    type = string
    default = "default"
    description = "The environment this cloud is setup for, and for which to mark resource with."
}

variable "aws-region" {
    type = string
    default = "eu-central-1"
    description = "The AWS region into which to deploy Crossbar.io FX cloud."
}

variable "aws-amis" {
    type = map(string)
    default = {
        # crossbario/crossbarfx:pypy-slim-amd64-20.7.1.dev6
        eu-central-1 = "ami-0d37f3544e1bb229a"
        eu-west-1 = "ami-0ec39498df467f85c"
    }
    description = "Map of Crossbar.io FX cloud AMIs to be used by region"
}

variable "aws-azs" {
    type = map(list(string))
    default = {
        # you must define exactly 3 AZs per region:
        eu-central-1 = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
        eu-west-1 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    }
    description = "Map of AWS regions to availability zones within region to be used for the deployment."
}

variable "cidr-prefix" {
    type = string
    default = "10.0."
    description = "IP subnet prefix to be used for the region, must be one from 10.0.0.0/16, eg 10.0. or 10.1."
}

variable "admin-pubkey" {
    type = string
    description = "Path to file with the SSH public key to install in the instances by default for SSH administration access."
}

variable "dns-domain-name" {
    type = string
    description = "The DNS domain name used in the cloud deployment, eg. example.com or my-cloud.example.com. You must own and control this (sub-)domain, as in, be able to configure the AWS nameservers to be used for the domain."
}

variable "domain-web-bucket" {
    type = string
    description = "Name of the S3 bucket used to host the static web content of the domain web site(s)."
}

variable "domain-weblog-bucket" {
    type = string
    description = "Name of the S3 bucket used to store web access logs for the domain web site(s)."
}

variable "domain-download-bucket" {
    type = string
    description = "Name of the S3 bucket used to host the downloadable content on the domain web site(s)."
}

variable "domain-backup-bucket" {
    type = string
    description = "Name of the S3 bucket used to host the snapshots and backups for the domain nodes."
}

variable "enable-tls" {
    type = string
    default = false
    description = "If enabled, generate and setup TLS certificates and TLS encrypted listening endpoints."
}

variable "enable-master" {
    type = string
    default = true
    description = "If enabled (default), create a Crossbar.io FX master node, auto-pairing all cluster nodes to the (auto-created) default management realm."
}

variable "enable-workbench" {
    type = string
    default = false
    description = "If enabled, create a Crossbar.io FX workbench node, with all cluster node directories in (read-only) access."
}

variable "enable-xbrmarket" {
    type = string
    default = false
    description = "If enabled, create a Crossbar.io FX XBR market node, hosting a XBR data market. A market operator may also use the workbench to access and analyze market (transactional) data."
}

variable "master-instance-type" {
    type = string
    default = "t3a.medium"
    description = "The AWS EC2 instance type to be used for the master node (if enabled)."
}

variable "master-port" {
    type = number
    default = 9000
    description = "Master node TCP listening port."
}

variable "workbench-instance-type" {
    type = string
    default = "t3a.medium"
    description = "The AWS EC2 instance type to be used for the workbench node (if enabled)."
}

variable "xbrmarket-instance-type" {
    type = string
    default = "t3a.medium"
    description = "The AWS EC2 instance type to be used for the XBR market node (if enabed)."
}

variable "dataplane-instance-type" {
    type = string
    default = "t3a.medium"
    description = "The AWS EC2 instance type to be used for the WAMP data-plane cluster nodes."
}

variable "dataplane-min-size" {
    type = number
    default = 2
    description = "Minimum number of instances started for the data-plane cluster."
}

variable "dataplane-desired-size" {
    type = number
    default = 2
    description = "Desired number of instances started for the data-plane cluster."
}

variable "dataplane-max-size" {
    type = number
    default = 30
    description = "Maximum number of instances started for the data-plane cluster."
}
