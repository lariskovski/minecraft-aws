#!/bin/bash
set -ex 

sudo cp /tmp/destroy-monitor* /home/minecraft/
ls -lah /tmp
sudo chown -R minecraft:minecraft /home/minecraft/destroy-monitor*
sudo chmod +x /home/minecraft/destroy-monitor.sh
ls -lah /home/minecraft

sudo pip3 install mcrcon requests

# Crontab entry
sudo bash -c "(crontab -l 2>/dev/null; echo \"*/20 * * * * source /etc/profile.d/script.sh; /home/minecraft/destroy-monitor.sh\") | crontab -"
