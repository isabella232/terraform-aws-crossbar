#!/bin/sh

# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

apt-get update
apt-get dist-upgrade -y
apt-get install -y expect binutils awscli
apt-get autoremove -y

INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`

cd /tmp
curl https://download.crossbario.com/crossbarfx/linux-amd64/crossbarfx-latest -o crossbarfx
chmod +x crossbarfx
cp crossbarfx /usr/local/bin/crossbarfx

# https://docs.aws.amazon.com/efs/latest/ug/installing-other-distro.html
git clone https://github.com/aws/efs-utils
cd efs-utils/
./build-deb.sh
apt-get -y install ./build/amazon-efs-utils*deb
cd ..

/usr/bin/docker pull crossbario/crossbarfx:pypy-slim-amd64

# we only need RO-access to "/web" as this is shared static web content
mkdir -p /web
echo "${file_system_id} /web efs _netdev,tls,accesspoint=${access_point_id_web},ro,auto 0 0" >> /etc/fstab
mount -a /web

# we (obviously) need RW-access to "/nodes/<PUBKEY>", but since we don't want to create an NFS access
# point per node, we RW-mount all node directories - BUT then only map the 1 node directory we actually
# need into the Docker container running our node
mkdir -p /nodes
echo "${file_system_id} /nodes efs _netdev,tls,accesspoint=${access_point_id_nodes},rw,auto 0 0" >> /etc/fstab
mount -a /nodes

# generate new node key pair
#
mkdir -p /tmp/.crossbar
crossbarfx keys --cbdir=/tmp/.crossbar
PUBKEY=`grep "public-key-ed25519:" /tmp/.crossbar/key.pub  | awk '{print $2}'`
HOSTNAME=`hostname`
mkdir /nodes/$PUBKEY
mv /tmp/.crossbar /nodes/$PUBKEY/

# remember vars in environment
#
echo "export CROSSBARFX_PUBKEY="$PUBKEY >> /home/ubuntu/.profile
echo "export CROSSBARFX_HOSTNAME="$HOSTNAME >> /home/ubuntu/.profile
echo "export CROSSBARFX_INSTANCE_ID="$INSTANCE_ID >> /home/ubuntu/.profile

# setup aws credentials mechanism
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html
mkdir /home/ubuntu/.aws/
aws_config="$(cat <<EOF
[profile default]
role_arn = arn:aws:iam::${aws_account_id}:role/crossbar-ec2iam-cluster
credential_source = Ec2InstanceMetadata
EOF
)"
echo "$aws_config" > /home/ubuntu/.aws/config
chown -R ubuntu:ubuntu /home/ubuntu/.aws
chmod 700 /home/ubuntu/.aws

# tag ec2 instance with crossbar node public key
aws ec2 create-tags --region ${aws_region} --resources $INSTANCE_ID --tags Key=pubkey,Value=$PUBKEY
aws ec2 describe-tags --region ${aws_region} --filters "Name=resource-id,Values=$INSTANCE_ID"

node_config="$(cat <<EOF
{
    "version": 2,
    "controller": {
        "enable_docker": true,
        "fabric": {
            "transport": {
                "type": "websocket",
                "url": "${master_url}",
                "endpoint": {
                    "type": "tcp",
                    "host": "${master_hostname}",
                    "port": ${master_port},
                    "timeout": 5
                }
            }
        }
    },
    "workers": [
        {
            "type": "router",
            "realms": [
                {
                    "name": "realm1",
                    "roles": [
                        {
                            "name": "anonymous",
                            "permissions": [
                                {
                                    "uri": "",
                                    "match": "prefix",
                                    "allow": {
                                        "call": true,
                                        "register": true,
                                        "publish": true,
                                        "subscribe": true
                                    },
                                    "disclose": {
                                        "caller": true,
                                        "publisher": true
                                    },
                                    "cache": true
                                }
                            ]
                        }
                    ]
                }
            ],
            "transports": [
                {
                    "type": "web",
                    "endpoint": {
                        "type": "tcp",
                        "port": 8080,
                        "backlog": 1024
                    },
                    "paths": {
                        "/": {
                            "type": "static",
                            "directory": "/web",
                            "options": {
                                "enable_directory_listing": true
                            }
                        },
                        "info": {
                            "type": "nodeinfo"
                        },
                        "autobahn": {
                            "type": "archive",
                            "archive": "autobahn-v20.2.1.zip",
                            "origin": "https://github.com/crossbario/autobahn-js-browser/archive/v20.2.1.zip",
                            "object_prefix": "autobahn-js-browser-20.2.1",
                            "default_object": "autobahn.min.js",
                            "download": true,
                            "cache": true,
                            "hashes": [
                                "b69cd17ac043cceceea8ed589a09a2555b5c39e32c2fea18ecc26dc5baf67de8"
                            ],
                            "mime_types": {
                                ".min.js": "text/javascript",
                                ".jgz": "text/javascript"
                            }
                        },
                        "ws": {
                            "type": "websocket",
                            "auth": {
                                "anonymous": {
                                    "type": "static",
                                    "role": "anonymous"
                                }
                            },
                            "serializers": [
                                "cbor", "msgpack", "json"
                            ],
                            "options": {
                                "allowed_origins": ["*"],
                                "allow_null_origin": true,
                                "enable_webstatus": true,
                                "max_frame_size": 1048576,
                                "max_message_size": 1048576,
                                "auto_fragment_size": 65536,
                                "fail_by_drop": true,
                                "open_handshake_timeout": 2500,
                                "close_handshake_timeout": 1000,
                                "auto_ping_interval": 10000,
                                "auto_ping_timeout": 5000,
                                "auto_ping_size": 4,
                                "compression": {
                                    "deflate": {
                                        "request_no_context_takeover": false,
                                        "request_max_window_bits": 13,
                                        "no_context_takeover": false,
                                        "max_window_bits": 13,
                                        "memory_level": 5
                                    }
                                }
                            }
                        }
                    }
                }
            ]
        }
    ]
}
EOF
)"
echo "$node_config" >> /nodes/$PUBKEY/.crossbar/config.json

chown -R ubuntu:ubuntu /nodes/$PUBKEY
chmod 700 /nodes/$PUBKEY

service_unit="$(cat <<EOF
[Unit]
Description=Crossbar.io FX (Edge)
After=syslog.target network.target nss-lookup.target network-online.target docker.service
Requires=network-online.target docker.service

[Service]
Type=simple
User=ubuntu
Group=ubuntu
StandardInput=null
StandardOutput=journal
StandardError=journal
TimeoutStartSec=0
Restart=always
ExecStart=/usr/bin/unbuffer /usr/bin/docker run --rm --name crossbarfx --net=host -t \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    -v /web:/web:ro \
    -v /nodes/$PUBKEY:/nodes/$PUBKEY:rw \
    crossbario/crossbarfx:pypy-slim-amd64 \
    edge start --cbdir=/nodes/$PUBKEY/.crossbar
ExecReload=/usr/bin/docker restart crossbarfx
ExecStop=/usr/bin/docker stop crossbarfx
ExecStopPost=-/usr/bin/docker rm -f crossbarfx

[Install]
WantedBy=multi-user.target
EOF
)"
echo "$service_unit" >> /etc/systemd/system/crossbarfx.service

systemctl daemon-reload
systemctl enable crossbarfx.service
systemctl restart crossbarfx.service

aliases="$(cat <<EOF
alias crossbarfx_start='sudo systemctl start crossbarfx'
alias crossbarfx_stop='sudo systemctl stop crossbarfx'
alias crossbarfx_restart='sudo systemctl restart crossbarfx'
alias crossbarfx_status='sudo systemctl status crossbarfx'
alias crossbarfx_logstail='sudo journalctl -f -u crossbarfx'
alias crossbarfx_logs='sudo journalctl -n200 -u crossbarfx'
EOF
)"
echo "$aliases" >> /home/ubuntu/.bashrc
