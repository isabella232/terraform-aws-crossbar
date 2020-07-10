## 1 - Start master node

![autoconfiguration-shot5](docs/autoconfiguration/shot5.png)

## 2 - Start edge node

![autoconfiguration-shot6](docs/autoconfiguration/shot6.png)
![autoconfiguration-shot7](docs/autoconfiguration/shot7.png)

## 3 - Restart edge node

![autoconfiguration-shot8](docs/autoconfiguration/shot8.png)

## Complete auto-configuration using Terraform

![autoconfiguration-shot9](docs/autoconfiguration/shot9.png)
![autoconfiguration-shot10](docs/autoconfiguration/shot10.png)
![autoconfiguration-shot11](docs/autoconfiguration/shot11.png)
![autoconfiguration-shot12](docs/autoconfiguration/shot12.png)


## Screenshots

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
![shot11](docs/shot11.png)
![shot12](docs/shot12.png)
![shot13](docs/shot13.png)

## Publish

List tags of current releases:

```console
git tag -l
```

Use an incremented tag for new release:

```console
git add . && git commit -m "updates" && git push && \
git tag -a v1.1.3 -m "tagged release" && git push --tags
```

## References

* https://earlruby.org/2019/01/creating-aws-efs-elastic-filesystems-with-terraform/
* https://github.com/manicminer/ansible-auto-scaling-tutorial
* https://registry.terraform.io/modules/devops-workflow/efs/aws/0.6.2
* https://www.terraform.io/docs/providers/aws/r/efs_file_system.html
* https://cwong47.gitlab.io/technology-terraform-aws-efs/
* https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#inventory-script-example-aws-ec2
* https://docs.ansible.com/ansible/latest/scenario_guides/guide_aws.html
* https://docs.ansible.com/ansible/latest/user_guide/playbooks.html
* https://www.grailbox.com/2020/04/how-to-set-up-a-domain-in-amazon-route-53-with-terraform/
* https://www.azavea.com/blog/2018/07/16/provisioning-acm-certificates-on-aws-with-terraform/
