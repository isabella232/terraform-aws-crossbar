# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

default:
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "  build        Build AMI using Packer."
	@echo "  version      Print version from Docker image."
	@echo "  plan         Plan Terraform deployment."
	@echo "  apply        Apply Terraform deployment."
	@echo "  destroy      Destroy Terraform deployment."
	@echo "  refresh      Refresh Terraform deployment."
	@echo "  list_nodes   List all nodes in auto-scaling group (core/edge nodes, not master)."
	@echo "  ping_nodes   Ping all nodes in auto-scaling group (will SSH into the instances)."
	@echo ""

build:
	packer build ./crossbarfx-ami.json

version:
	docker run --rm crossbario/crossbarfx:pypy-slim-amd64 version

init:
	terraform init \
		-var PRIVKEY=${HOME}/.ssh/id_rsa \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="idma2020.de" \
		-var DOMAIN_ID="idma2020de"

plan:
	terraform plan \
		-var PRIVKEY=${HOME}/.ssh/id_rsa \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="idma2020.de" \
		-var DOMAIN_ID="idma2020de"

apply:
	terraform apply \
		-var PRIVKEY=${HOME}/.ssh/id_rsa \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="idma2020.de" \
		-var DOMAIN_ID="idma2020de"

destroy:
	terraform destroy \
		-var PRIVKEY=${HOME}/.ssh/id_rsa \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="idma2020.de" \
		-var DOMAIN_ID="idma2020de"

refresh:
	terraform refresh \
		-var PRIVKEY=${HOME}/.ssh/id_rsa \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="idma2020.de" \
		-var DOMAIN_ID="idma2020de"

list_nodes:
	ansible-inventory -i aws_ec2.yml --graph

ping_nodes:
	ansible all -i aws_ec2.yml -m ping --private-key=~/.ssh/id_rsa -u ubuntu

# The current implementation of Terraform import can only import resources into the state.
# It does not generate configuration. A future version of Terraform will also generate configuration.
import:
	terraform import aws_route53_zone.idma2020de Z2491LS7TIYD1L
