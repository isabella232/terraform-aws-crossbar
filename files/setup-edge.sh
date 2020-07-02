#!/bin/sh

# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

apt-get update
apt-get dist-upgrade -y
apt-get install -y expect binutils
apt-get autoremove -y

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

mkdir -p /node
echo "${file_system_id} /node efs _netdev,tls,accesspoint=${access_point_id_nodes} 0 0" >> /etc/fstab
mount -a /node

mkdir -p /tmp/.crossbar
crossbarfx keys --cbdir=/tmp/.crossbar
PUBKEY=`grep "public-key-ed25519:" /tmp/.crossbar/key.pub  | awk '{print $2}'`
mkdir /node/$PUBKEY
mv /tmp/.crossbar /node/$PUBKEY/

echo "export CROSSBARFX_PUBKEY="$PUBKEY >> ~/.profile

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
                            "directory": "../web",
                            "options": {
                                "enable_directory_listing": false
                            }
                        },
                        "info": {
                            "type": "nodeinfo"
                        },
                        "shared": {
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
echo "$node_config" >> /node/$PUBKEY/.crossbar/config.json

chown -R ubuntu:ubuntu /node/$PUBKEY
chmod 700 /node/$PUBKEY

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
    -v /node/$PUBKEY:/node \
    crossbario/crossbarfx:pypy-slim-amd64 \
    edge start --cbdir=/node/.crossbar
ExecReload=/usr/bin/docker restart %n
ExecStop=/usr/bin/docker stop %n
ExecStopPost=-/usr/bin/docker rm -f %n

[Install]
WantedBy=multi-user.target
EOF
)"
echo "$service_unit" >> /etc/systemd/system/crossbarfx.service

systemctl daemon-reload
systemctl enable crossbarfx.service
systemctl restart crossbarfx.service
