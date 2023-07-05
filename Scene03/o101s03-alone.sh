#!/bin/bash
echo -e 'root\nroot' | passwd root
apt-get -y update
apt-get install -y openssh-server
sed -i '/^PermitRootLogin/d' /etc/ssh/sshd_config
bash -c 'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config'
systemctl restart sshcat 