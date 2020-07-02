# Terraform based setup of Crossbar.io FX


module "crossbarfx" {
    source  = "crossbario/crossbarfx/aws"
    version = "1.0.0"
    PRIVKEY=${HOME}/.ssh/id_rsa
    PUBKEY=${HOME}/.ssh/id_rsa.pub
    DOMAIN_NAME="tentil.es"
    DOMAIN_ID="tentiles"
}

PRIVKEY=${HOME}/.ssh/id_rsa \
PUBKEY=${HOME}/.ssh/id_rsa.pub \
DOMAIN_NAME="idma2020.de" \
DOMAIN_ID="idma2020de"


## Create your AWS zone

In this example, we setup everything to have our new cluster host WAMP application routing, Web services and optionally XBR data market services for our domain

* **tentil.es**

We start by opening the AWS Route 53 console, creating a new AWS **zone** to be
used with our domain:

![shot12](docs/shot12.png)

A new zone with Zone ID **Z07225043POQ86QQZSHMF** was created here.

![shot12b](docs/shot12b.png)

Open the zone and click on the NS record that was created automatically:

![shot13](docs/shot13.png)

This record refers to the DNS nameservers that must be used for this zone.

## Configure your DNS domain

Next, at your DNS registrar, configure the AWS nameservers of your zone

```
ns-122.awsdns-15.com
ns-926.awsdns-51.net
ns-2043.awsdns-63.co.uk
ns-1040.awsdns-02.org
```

that apply for your domain.

![shot11](docs/shot11.png)

After configuration, the new nameservers need to propagate the DNS system.

Once that has happened (which may take several minutes to half an hour), resolving
your domain should look like:

```console
```


* [http://idma2020.de/](http://idma2020.de/)
* [https://idma2020.de/](https://idma2020.de/)


```console
cd root
terraform init
terraform plan
terraform apply
```

```console
ssh ubuntu@ec2-18-197-158-103.eu-central-1.compute.amazonaws.com
```

```console
sudo systemctl status crossbarfx
sudo journalctl -n200 -u crossbarfx
```

```console
...
Jul 02 13:00:44 ip-10-0-10-77 unbuffer[3300]: 2020-07-02T13:00:44+0000 [Router         12] denied unpaired CF node with pubkey 2a7d14f3fcab9bd9d09ad0c7ea9c60fc638ebf096a1a565217ef517687ac48af
Jul 02 13:00:44 ip-10-0-10-77 unbuffer[3300]: 2020-07-02T13:00:44+0000 [Router         12] Authenticator.onUserError(): "fabric.auth-failed.node-unpaired: This node is unpaired. Please pair the node with management realm first."
...
```

```console
crossbarfx shell create mrealm mrealm1
crossbarfx shell pair node 2a7d14f3fcab9bd9d09ad0c7ea9c60fc638ebf096a1a565217ef517687ac48af mrealm1 node1
crossbarfx shell pair node 84d630d688763b6af127882c1ce82c57905b1bcd8f1c4af4aa7155424b3e4147 mrealm1 node2
crossbarfx shell --realm mrealm1 list nodes
crossbarfx shell --realm mrealm1 show node node1
crossbarfx shell --realm mrealm1 show node node2
```

```console
...
Jul 02 13:01:08 ip-10-0-10-77 unbuffer[3300]: 2020-07-02T13:01:08+0000 [Router         12] authenticated managed node "6d6ff6d4-6f7d-4d23-8ab5-6090d3233ea3" with pubkey "0x2a7d14f3fcab9bd9.." on management realm "mrealm1" (authrole="node") <crossbarfx.master.node.authenticat
...
```


```console
(cpy382_1) oberstet@intel-nuci7:~/scm/crossbario/crossbario-devops/terraform/root$ ansible aws_region_eu_central_1 -i aws_ec2.yml -m ping --private-key=~/.ssh/id_rsa -u ubuntu
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ec2-18-197-158-103.eu-central-1.compute.amazonaws.com should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will default to using
the discovered platform python for this host. See https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12. Deprecation warnings can be disabled by setting
deprecation_warnings=False in ansible.cfg.
ec2-18-197-158-103.eu-central-1.compute.amazonaws.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ec2-18-184-158-203.eu-central-1.compute.amazonaws.com should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will default to using
the discovered platform python for this host. See https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12. Deprecation warnings can be disabled by setting
deprecation_warnings=False in ansible.cfg.
ec2-18-184-158-203.eu-central-1.compute.amazonaws.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ec2-3-123-30-8.eu-central-1.compute.amazonaws.com should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will default to using the
discovered platform python for this host. See https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False
in ansible.cfg.
ec2-3-123-30-8.eu-central-1.compute.amazonaws.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
(cpy382_1) oberstet@intel-nuci7:~/scm/crossbario/crossbario-devops/terraform/root$ ansible aws_region_us_east_1 -i aws_ec2.yml -m ping --private-key=~/.ssh/id_rsa -u ubuntu
[WARNING]: Could not match supplied host pattern, ignoring: aws_region_us_east_1
[WARNING]: No hosts matched, nothing to do
(cpy382_1) oberstet@intel-nuci7:~/scm/crossbario/crossbario-devops/terraform/root$
```



## Packer

The Terraform based setup on AWS is based on AMIs which come with Docker and Crossbar.io FX preinstalled.

We use [HashiCorp Packer](https://www.packer.io/) to bake AMI images directly from our Crossbar.io FX Docker images.

To rebuild and publish AMI images after a new Crossbar.io FX Docker image has been published, run:

```console
make build
```

Note the AMI ID printed, and update [root/variables.tf](root/variables.tf) accordingly, eg

* CrossbarFX 20.6.2: **ami-06ca2353bcdf3ac29**

Here is the log for above:

```console
oberstet@intel-nuci7:~/scm/crossbario/crossbario-devops/terraform$ make build
...
==> amazon-ebs: Digest: sha256:32b6329873e0a755121e18f7757874de24d4a557108cf4d1b36903a7cae669ad
==> amazon-ebs: Status: Downloaded newer image for crossbario/crossbarfx:pypy-slim-amd64
    amazon-ebs:
    amazon-ebs:     :::::::::::::::::
    amazon-ebs:           :::::          _____                 __              _____  __
    amazon-ebs:     :::::   :   :::::   / ___/______  ___ ___ / /  ___ _____  / __/ |/_/
    amazon-ebs:     :::::::   :::::::  / /__/ __/ _ \(_-<(_-</ _ \/ _ `/ __/ / _/_>  <
    amazon-ebs:     :::::   :   :::::  \___/_/  \___/___/___/_.__/\_,_/_/   /_/ /_/|_|
    amazon-ebs:           :::::
    amazon-ebs:     :::::::::::::::::   Crossbar.io FX v20.6.2 [00000]
    amazon-ebs:
    amazon-ebs:     Copyright (c) 2013-2020 Crossbar.io Technologies GmbH. All rights reserved.
    amazon-ebs:
    amazon-ebs:  Crossbar.io        : 20.6.2
    amazon-ebs:    txaio            : 20.4.1
    amazon-ebs:    Autobahn         : 20.6.2
    amazon-ebs:      UTF8 Validator : autobahn
    amazon-ebs:      XOR Masker     : autobahn
    amazon-ebs:      JSON Codec     : stdlib
    amazon-ebs:      MsgPack Codec  : umsgpack-2.6.0
    amazon-ebs:      CBOR Codec     : cbor-1.0.0
    amazon-ebs:      UBJSON Codec   : ubjson-0.16.1
    amazon-ebs:      FlatBuffers    : flatbuffers-1.12
    amazon-ebs:    Twisted          : 20.3.0-EPollReactor
    amazon-ebs:    LMDB             : 0.98/lmdb-0.9.22
    amazon-ebs:    Python           : 3.6.9/PyPy-7.3.0
    amazon-ebs:  CrossbarFX         : 20.6.2
    amazon-ebs:    NumPy            : 1.15.4
    amazon-ebs:    zLMDB            : 20.4.1
    amazon-ebs:  Frozen executable  : no
    amazon-ebs:  Operating system   : Linux-5.3.0-1023-aws-x86_64-with-debian-9.11
    amazon-ebs:  Host machine       : x86_64
    amazon-ebs:  Release key        : RWQHer9KKmNsqP057xopw37DfYE8pl92aOWU5E+OWdhlwtCns7nlKjpE
    amazon-ebs:
==> amazon-ebs: Stopping the source instance...
    amazon-ebs: Stopping instance
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating AMI crossbarfx-ami-1593617540 from instance i-05911e29903bfff0a
    amazon-ebs: AMI: ami-06ca2353bcdf3ac29
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-central-1: ami-06ca2353bcdf3ac29

(cpy382_1) oberstet@intel-nuci7:~/scm/crossbario/crossbario-devops/terraform$
```






## Terraform

# https://github.com/nbering/terraform-provider-ansible/releases

# unzip ~/Downloads/terraform-provider-ansible-linux_amd64.zip
# mv linux_amd64/terraform-provider-ansible_v1.0.3 ~/.terraform.d/plugins/
# mkdir -p ~/.terraform.d/plugins
# ansible-playbook -i inventory site.yml


https://docs.aws.amazon.com/efs/latest/ug/installing-other-distro.html

sudo apt-get -y install binutils
git clone https://github.com/aws/efs-utils
cd efs-utils/
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb



sudo apt-get install nfs-common



sudo mkdir -p /mnt/efs
sudo mount -t efs -o tls,accesspoint=fsap-0ce9961e2246d9b38 fs-af0986f7 /mnt/efs


/etc/fstab

file-system-id efs-mount-point efs _netdev,tls,accesspoint=access-point-id 0 0




![shot1](docs/shot1.png)
![shot2](docs/shot2.png)
![shot3](docs/shot3.png)
![shot4](docs/shot4.png)
![shot5](docs/shot5.png)
![shot6](docs/shot6.png)
![shot7](docs/shot7.png)
![shot8](docs/shot8.png)
![shot9](docs/shot9.png)
![shot10](docs/shot10.png)

* https://earlruby.org/2019/01/creating-aws-efs-elastic-filesystems-with-terraform/
* https://github.com/manicminer/ansible-auto-scaling-tutorial
* https://registry.terraform.io/modules/devops-workflow/efs/aws/0.6.2
* https://www.terraform.io/docs/providers/aws/r/efs_file_system.html
* https://cwong47.gitlab.io/technology-terraform-aws-efs/
* https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#inventory-script-example-aws-ec2
* https://docs.ansible.com/ansible/latest/scenario_guides/guide_aws.html
* https://docs.ansible.com/ansible/latest/user_guide/playbooks.html


```console
ssh ubuntu@ec2-35-172-209-112.compute-1.amazonaws.com sh -c 'hostname && cd ~/scm/crossbario/crossbario-devops/data_xbr_network/ && docker-compose up -d node'
```


```console
wget https://raw.githubusercontent.com/nbering/terraform-inventory/master/terraform.py
chmod +x terraform.py
sudo mv terraform.py /usr/local/bin/
ansible-playbook -i /usr/local/bin/terraform.py playbook.yml
```


```console
oberstet@intel-nuci7:~/scm/crossbario/crossbario-devops/terraform$ make

Targets:

  build        Build AMI using Packer.
  plan         Plan Terraform deployment.
  apply        Apply Terraform deployment.

(cpy382_1) oberstet@intel-nuci7:~/scm/crossbario/crossbario-devops/terraform$ make plan
terraform plan \
	-var pubkey=/home/oberstet/.ssh/id_rsa.pub \
	-var domain_name="idma2020.de" \
	-var domain_id="idma2020de"
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_key_pair.keypair1: Refreshing state... [id=keypair1]
aws_route53_zone.zone: Refreshing state... [id=Z05794152S3KILKJM7VJB]
aws_vpc.vpc1: Refreshing state... [id=vpc-0b28a29018a2d05b8]
aws_acm_certificate.cert: Refreshing state... [id=arn:aws:acm:eu-central-1:931347297591:certificate/11dca57c-650f-4a6a-863d-4d50f494eed3]
aws_route53_record.cert_validation: Refreshing state... [id=Z05794152S3KILKJM7VJB__481c71641048ec21eb5a55b9eb930c77.idma2020.de._CNAME]
aws_route53_record.cert_validation_alt1: Refreshing state... [id=Z05794152S3KILKJM7VJB__50c478a887e84c80f8185508aee15930.www.idma2020.de._CNAME]
aws_route53_record.zone_ns: Refreshing state... [id=Z05794152S3KILKJM7VJB_idma2020.de_NS]
aws_subnet.vpc1-private-3: Refreshing state... [id=subnet-01df4a08255e94e94]
aws_subnet.vpc1-private-1: Refreshing state... [id=subnet-06369a11a72ec1b62]
aws_subnet.vpc1-private-2: Refreshing state... [id=subnet-0cba10d59d55f69de]
aws_subnet.vpc1-public-3: Refreshing state... [id=subnet-0efbbf200d8b3ba17]
aws_subnet.vpc1-public-2: Refreshing state... [id=subnet-02fc4aca0d01d1257]
aws_internet_gateway.vpc1-gw: Refreshing state... [id=igw-0e811fd5974264d8e]
aws_subnet.vpc1-public-1: Refreshing state... [id=subnet-04e2bb1f2a2ce2313]
aws_route_table.vpc1-public: Refreshing state... [id=rtb-02f3abb24cb032d94]
aws_security_group.elb-securitygroup: Refreshing state... [id=sg-0abd1e98ece9542d9]
aws_route_table_association.vpc1-public-3-a: Refreshing state... [id=rtbassoc-0c96f1389724231b0]
aws_route_table_association.vpc1-public-2-a: Refreshing state... [id=rtbassoc-06e75872d47051f15]
aws_route_table_association.vpc1-public-1-a: Refreshing state... [id=rtbassoc-01d3cbca580c3e35b]
aws_security_group.myinstance: Refreshing state... [id=sg-015bdc05dc410a7b8]
aws_elb.elb1: Refreshing state... [id=elb1]
aws_launch_configuration.launchconfig1: Refreshing state... [id=launchconfig120200628135320590700000001]
aws_autoscaling_group.autoscaling1: Refreshing state... [id=autoscaling1]
aws_autoscaling_policy.example-cpu-policy: Refreshing state... [id=example-cpu-policy]
aws_autoscaling_policy.example-cpu-policy-scaledown: Refreshing state... [id=example-cpu-policy-scaledown]
aws_acm_certificate_validation.cert: Refreshing state... [id=2020-06-28 12:18:39 +0000 UTC]
aws_cloudwatch_metric_alarm.example-cpu-alarm: Refreshing state... [id=example-cpu-alarm]
aws_cloudwatch_metric_alarm.example-cpu-alarm-scaledown: Refreshing state... [id=example-cpu-alarm-scaledown]

------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
(cpy382_1) oberstet@intel-nuci7:~/scm/crossbario/crossbario-devops/terraform$
```

## GitHub actions

https://www.terraform.io/docs/github-actions/setup-terraform.html




## Initial setup

```console
ubuntu@ip-10-0-10-86:~$ crossbarfx shell auth


    Welcome to Crossbar.io Shell v20.6.2

    Press Ctrl-C to cancel the current command, and Ctrl-D to exit the shell.
    Type "help" to get help. Try TAB for auto-completion.

    Connection:

        url         : ws://localhost:9000/ws
        authmethod  : cryptosign
        realm       : com.crossbario.fabric
        authid      : superuser
        authrole    : user
        session     : 866532183702381

ubuntu@ip-10-0-10-86:~$ crossbarfx shell create mrealm mrealm1

{'cf_container_worker': '00000000-0000-0000-0000-000000000000',
 'cf_node': '00000000-0000-0000-0000-000000000000',
 'cf_router_worker': '00000000-0000-0000-0000-000000000000',
 'created': 1593547686617307,
 'name': 'mrealm1',
 'oid': '148055e6-3347-43fc-a078-b6b1f3a9567b',
 'owner': '96a00afd-09aa-4366-931d-9f7e0cf0e12a'}
ubuntu@ip-10-0-10-86:~$ sudo mount -a /node
ubuntu@ip-10-0-10-86:~$ ll /node/
total 20
drwx------  5 ubuntu ubuntu 6144 Jun 30 20:04 ./
drwxr-xr-x 25 root   root   4096 Jun 30 20:02 ../
drwx------  3 ubuntu ubuntu 6144 Jun 30 20:04 803ae49ec4be5fbcb2563999bfabfc1145a3811b54cca94450399aa4f282b82f/
drwx------  3 ubuntu ubuntu 6144 Jun 30 20:04 c850c7b017779ac00e1afe8526d4d76e12353e9b2d8b9bdaea6eea7a324039a0/
drwx------  3 ubuntu ubuntu 6144 Jun 30 20:04 d432e7a383c60274bcac760ee54a95ea9517cff6d84f43cec1b93cf75d6055c8/
ubuntu@ip-10-0-10-86:~$ crossbarfx shell pair node 803ae49ec4be5fbcb2563999bfabfc1145a3811b54cca94450399aa4f282b82f mrealm1 node1

{'authextra': None,
 'authid': 'node1',
 'mrealm_oid': '148055e6-3347-43fc-a078-b6b1f3a9567b',
 'oid': '2ad32a3b-f4cd-4fba-8e85-0efc2b87e650',
 'owner_oid': '96a00afd-09aa-4366-931d-9f7e0cf0e12a',
 'pubkey': '803ae49ec4be5fbcb2563999bfabfc1145a3811b54cca94450399aa4f282b82f'}
ubuntu@ip-10-0-10-86:~$ crossbarfx shell pair node c850c7b017779ac00e1afe8526d4d76e12353e9b2d8b9bdaea6eea7a324039a0 mrealm1 node2

{'authextra': None,
 'authid': 'node2',
 'mrealm_oid': '148055e6-3347-43fc-a078-b6b1f3a9567b',
 'oid': '002abf16-d4f1-4a45-8786-140f49a2a774',
 'owner_oid': '96a00afd-09aa-4366-931d-9f7e0cf0e12a',
 'pubkey': 'c850c7b017779ac00e1afe8526d4d76e12353e9b2d8b9bdaea6eea7a324039a0'}
ubuntu@ip-10-0-10-86:~$ crossbarfx shell pair node d432e7a383c60274bcac760ee54a95ea9517cff6d84f43cec1b93cf75d6055c8 mrealm1 node3

{'authextra': None,
 'authid': 'node3',
 'mrealm_oid': '148055e6-3347-43fc-a078-b6b1f3a9567b',
 'oid': '172b58de-0c73-4ef6-94d6-c0d0b58ad553',
 'owner_oid': '96a00afd-09aa-4366-931d-9f7e0cf0e12a',
 'pubkey': 'd432e7a383c60274bcac760ee54a95ea9517cff6d84f43cec1b93cf75d6055c8'}
ubuntu@ip-10-0-10-86:~$
ubuntu@ip-10-0-10-86:~$ crossbarfx shell --realm mrealm1 list nodes

['2ad32a3b-f4cd-4fba-8e85-0efc2b87e650',
 '002abf16-d4f1-4a45-8786-140f49a2a774',
 '172b58de-0c73-4ef6-94d6-c0d0b58ad553']
ubuntu@ip-10-0-10-86:~$ crossbarfx shell --realm mrealm1 show node node1

{'authextra': None,
 'authid': 'node1',
 'heartbeat': None,
 'mrealm_oid': '148055e6-3347-43fc-a078-b6b1f3a9567b',
 'oid': '2ad32a3b-f4cd-4fba-8e85-0efc2b87e650',
 'owner_oid': '96a00afd-09aa-4366-931d-9f7e0cf0e12a',
 'pubkey': '803ae49ec4be5fbcb2563999bfabfc1145a3811b54cca94450399aa4f282b82f',
 'status': 'online',
 'timestamp': 1593547888395839744}
ubuntu@ip-10-0-10-86:~$ crossbarfx shell --realm mrealm1 show node node2

{'authextra': None,
 'authid': 'node2',
 'heartbeat': None,
 'mrealm_oid': '148055e6-3347-43fc-a078-b6b1f3a9567b',
 'oid': '002abf16-d4f1-4a45-8786-140f49a2a774',
 'owner_oid': '96a00afd-09aa-4366-931d-9f7e0cf0e12a',
 'pubkey': 'c850c7b017779ac00e1afe8526d4d76e12353e9b2d8b9bdaea6eea7a324039a0',
 'status': 'online',
 'timestamp': 1593547887389204480}
ubuntu@ip-10-0-10-86:~$ crossbarfx shell --realm mrealm1 show node node3

{'authextra': None,
 'authid': 'node3',
 'heartbeat': None,
 'mrealm_oid': '148055e6-3347-43fc-a078-b6b1f3a9567b',
 'oid': '172b58de-0c73-4ef6-94d6-c0d0b58ad553',
 'owner_oid': '96a00afd-09aa-4366-931d-9f7e0cf0e12a',
 'pubkey': 'd432e7a383c60274bcac760ee54a95ea9517cff6d84f43cec1b93cf75d6055c8',
 'status': 'online',
 'timestamp': 1593547894794971648}
ubuntu@ip-10-0-10-86:~$
```
