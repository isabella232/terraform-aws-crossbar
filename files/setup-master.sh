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

sudo -u ubuntu CROSSBAR_FABRIC_URL="ws://localhost:${master_port}/ws" /usr/local/bin/crossbarfx shell auth --yes

# https://docs.aws.amazon.com/efs/latest/ug/installing-other-distro.html
git clone https://github.com/aws/efs-utils
cd efs-utils/
./build-deb.sh
apt-get -y install ./build/amazon-efs-utils*deb
cd ..

/usr/bin/docker pull crossbario/crossbarfx:pypy-slim-amd64

mkdir -p /nodes
echo "${file_system_id} /nodes efs _netdev,tls,accesspoint=${access_point_id_nodes} 0 0" >> /etc/fstab
mount -a /nodes

mkdir -p /master
echo "${file_system_id} /master efs _netdev,tls,accesspoint=${access_point_id_master} 0 0" >> /etc/fstab
mount -a /master

mkdir -p /master/.crossbar
crossbarfx keys --cbdir=/master/.crossbar
PUBKEY=`grep "public-key-ed25519:" /master/.crossbar/key.pub  | awk '{print $2}'`

node_config="$(cat <<EOF
{
    "version": 2,
    "workers": [
        {
            "transports": [
                "COPY",
                "COPY",
                {
                    "endpoint": {
                        "type": "tcp",
                        "port": ${master_port},
                        "backlog": 1024
                    }
                }
            ]
        },
        "COPY"
    ]
}
EOF
)"
echo "$node_config" > /master/.crossbar/config.json

chown -R ubuntu:ubuntu /master
chmod 700 /master

# CROSSBAR_FABRIC_SUPERUSER=/home/oberstet/.crossbarfx/default.pub
# CROSSBAR_FABRIC_URL=ws://localhost:9000/ws
# CROSSBARFX_WATCH_TO_PAIR=/tmp/nodes

service_unit="$(cat <<EOF
[Unit]
Description=Crossbar.io FX (Master)
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
    -v /master:/master:rw \
    -v /home/ubuntu/.crossbarfx:/master/.crossbarfx:ro \
    -v /nodes:/nodes:ro \
    -e CROSSBAR_FABRIC_URL=${master_url} \
    -e CROSSBARFX_WATCH_TO_PAIR=/nodes \
    -e CROSSBAR_FABRIC_SUPERUSER=/master/.crossbarfx/default.pub \
    crossbario/crossbarfx:pypy-slim-amd64 \
    master start --cbdir=/master/.crossbar
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
alias crossbarfx_stop='sudo systemctl stop crossbarfx'
alias crossbarfx_restart='sudo systemctl restart crossbarfx'
alias crossbarfx_status='sudo systemctl status crossbarfx'
alias crossbarfx_logstail='sudo journalctl -f -u crossbarfx'
alias crossbarfx_logs='sudo journalctl -n200 -u crossbarfx'
EOF
)"
echo "$aliases" >> /home/ubuntu/.bashrc
