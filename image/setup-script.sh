#!/bin/bash
set -ex

# Configures minecraft user, group and home dir
sudo adduser --system --user-group --create-home minecraft

# Updates packages, install JRE and other dependencies
sudo yum update -y && \
sudo yum install -y java-17-amazon-corretto-headless wget amazon-efs-utils

# Set timezone
sudo timedatectl set-timezone America/Sao_Paulo

# Systemd Service
sudo bash -c 'cat <<EOF >/etc/systemd/system/minecraft-server.service
[Unit]
Description=Start and stop the minecraft-server
[Service]
WorkingDirectory=/home/minecraft
User=minecraft
Group=minecraft
Restart=on-failure
RestartSec=20 5
ExecStart=/usr/bin/java -Xms1G -Xmx4G -jar server.jar nogui
[Install]
WantedBy=multi-user.target
EOF'

# Configure fstab to mounts EFS on boot
sudo bash -c "echo 'efs.minecraft.internal:/ /home/minecraft efs defaults,_netdev 0 0' >> /etc/fstab"
sudo mount -a

# Downloads actual server first time server is being configured on EFS
if [ ! -d /home/minecraft/world ]
then
    cd /home/minecraft
    # https://www.minecraft.net/en-us/download/server
    wget https://launcher.mojang.com/v1/objects/e00c4052dac1d59a1188b2aa9d5a87113aaf1122/server.jar && \
    java -Xms1G -Xmx4G -jar server.jar nogui || true
    sed -i.bak s/false/true/g eula.txt && \
    sed -i.bak s/online-mode=true/online-mode=false/g server.properties
    # Adjusts home permission
    sudo chown minecraft:minecraft -R /home/minecraft
else
    echo "World already on disk."
fi

# Get server up and running on boot
sudo systemctl enable minecraft-server
