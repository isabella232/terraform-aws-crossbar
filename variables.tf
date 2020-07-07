# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

variable "AWS_REGION" {
    type = string
    default = "eu-central-1"
}

variable "AWS_AZ" {
    type = list(string)
    default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "AMIS" {
    type = map(string)
    default = {
        # crossbario/crossbarfx:pypy-slim-amd64-20.7.1.dev6
        eu-central-1 = "ami-0c26335be1d90838f"
    }
}

variable "INSTANCE_TYPE" {
    type = string
    default = "t3a.medium"
}

variable "PUBKEY" {
    type = string
}

variable "DOMAIN_ID" {
    type = string
}

variable "DOMAIN_NAME" {
    type = string
}

variable "ENABLE_TLS" {
    type = string
    default = false
}

variable "min_size" {
    type = number
    default = 1
}

variable "max_size" {
    type = number
    default = 30
}

variable "desired_capacity" {
    type = number
    default = 3
}
