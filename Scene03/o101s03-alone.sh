#!/bin/bash
echo 'root' | passwd --stdin root
apt-get update
apt-get install -y openssh-server
sed -i '/^PermitRootLogin/d' /etc/ssh/sshd_config
bash -c 'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config'
systemctl restart sshcat 