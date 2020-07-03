# Terraform based setup of Crossbar.io FX

DevOps is infrastructure as code

It’s always been HashiCorp’s position that the best way to provision infrastructure is to store your infrastructure as code (IaC) configuration files in a VCS repository and use Terraform to create resources based on them. This process typically has three steps:

    Write infrastructure as code
    Manage configuration files in VCS
    Automate infrastructure provisioning


Linking your Terraform Cloud workspace to a VCS repository




[Terraform Provider for AWS](https://terraform.io/docs/providers/aws/index.html)

cd myenv1
main.tf

terraform workspace myenv1
terraform init

terraform plan
terraform apply




The following will create and deploy a Crossbar.io FX based cluster in AWS
with two edge nodes and one master node.

Install Terraform. Then, create a new empty directory and a file `main.tf`
with this contents:

```hcl
module "crossbarfx" {
    source  = "crossbario/crossbarfx/aws"
    version = "1.1.0"

    # your AWS keypair
    PRIVKEY = "~/.ssh/id_rsa"
    PUBKEY = "~/.ssh/id_rsa.pub"

    # where to deploy to
    AWS_REGION = "eu-central-1"
    AWS_AZ = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

    # what instance type to use (for both master and edge nodes)
    INSTANCE_TYPE = "t3a.medium"

    # for which DNS domain to host
    DOMAIN_NAME = "tentil.es"
    DOMAIN_ID = "tentiles"

    # setup TLS certificates and all that (note: this can only be activated once the domain nameservers do work)
    ENABLE_TLS = false
}
```

Adjust `DOMAIN_NAME` and `DOMAIN_ID` (at least).

Now run:

```console
terraform init
```

and

```console
terraform apply
```

To remove everything from AWS again, run:


```console
terraform destroy
```
