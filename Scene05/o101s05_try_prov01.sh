#!/bin/bash

# Author: Daewon Kim
# Copyright 2023 Daewon Kim (prudentcircle@smsolutions.co.kr)
# This script provisions an instance needed for Scene05 "보여줘김선임" of OGJS-101.
# Designed to run on a Debian 12 VM.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo -e 'root\nroot' | passwd root
hostnamectl set-hostname o101s05-try01
apt-get -y update
apt-get install -y openssh-server parted xfsprogs spell less python3-pip python3-full python3-venv cowsay
sed -i '/^PermitRootLogin/d' /etc/ssh/sshd_config
bash -c 'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config'
systemctl restart ssh

cat << EOF > /etc/locale.conf
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8 
LC_NUMERIC=en_US.UTF-8
LC_TIME=en_US.UTF-8
LC_COLLATE=en_US.UTF-8
LC_MONETARY=en_US.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_PAPER=en_US.UTF-8
LC_NAME=en_US.UTF-8
LC_ADDRESS=en_US.UTF-8
LC_TELEPHONE=en_US.UTF-8
LC_MEASUREMENT=en_US.UTF-8
LC_IDENTIFICATION=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

mkdir -p /tmp/openstack/glance
mkdir -p /tmp/openstack/cinder
mkdir -p /tmp/newjeans/

/usr/games/cowsay -f cheese "ongojishin-101" > /tmp/openstack/picture01.txt
/usr/games/cowsay -f unipony-smaller "ongojishin-101" > /tmp/openstack/picture02.txt
/usr/games/cowsay -f hellokitty "ongojishin-101" > /tmp/openstack/picture03.txt
/usr/games/cowsay -f kangaroo "ongojishin-101" > /tmp/openstack/picture04.txt
/usr/games/cowsay -f moofasa "ongojishin-101" > /tmp/openstack/picture05.txt
/usr/games/cowsay -f skeleton "ongojishin-101" > /tmp/openstack/picture06.txt

touch /tmp/openstack/glance/conn_pool_min_size
touch /tmp/openstack/glance/rpc_zmq_bind_address
touch /tmp/openstack/glance/rpc_retry_attempts
touch /tmp/openstack/glance/log_date_format

touch /tmp/openstack/cinder/snapshot_same_host
touch /tmp/openstack/cinder/cloned_volume_same_az
touch /tmp/openstack/cinder/reserved_percentage
touch /tmp/openstack/cinder/volume_clear_ionice

cat << EOF > /tmp/newjeans/supershy.txt
⢿⢻⢻⣿⡟⠻⠻⣿⡿⠻⠟⣿⣿⠟⢿⣿⣿⢿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡿⠋⠀⠙
⣾⣸⣾⣿⣦⡀⣠⣿⣧⣀⣠⣿⣿⣄⣼⣿⣯⣼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡖⠋⣩⣄⠀⠀⢀
⢿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡸⠋⠀⠀⠀⠀⠀⠀⢀⣀⡤⠾⠟⠋⠀⠀⠈⠋⠀⠀⠙
⣾⣿⣿⣿⣷⣤⣼⣿⣿⣬⣽⣿⣿⣤⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡤⠶⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⣏⣿⣿⣿⣿⣻⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣤⣤⣤⢤⣶⣶⣶⣾⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣏⣿⣿⣿⣟⣁⣹⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⣌⣿⣿⣭⠁⣹⣿⣁⡁⣿
⣿⣿⣿⣿⣿⢿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⡿⣿⣿
⣼⣹⣿⣿⣇⣰⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣉⣉⣽⣿⡀⣀⣿
⢿⢻⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡟⣿⣿⣿⣿⣿⣿
⣾⣼⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡞⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢷⣘⣿⣿⣆⣁⣿
⢿⣿⣿⣿⠁⠀⠔⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢯⣻⣿⣿⣿⣿
⣾⣾⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿
⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣾⣿⣝⠛⢦⡾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿
⣿⣿⣿⣷⠀⠀⣠⣶⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⡇⠈⣿⠋⠀⠀⠀⢀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣿⣿⣿
⣏⣽⣿⣿⣄⣨⣿⣿⣿⠉⢷⡀⠀⠀⠀⠀⠀⠀⠀⣹⣯⣈⣽⣿⣷⠀⠈⢀⣠⡤⠒⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣫⣏⣽
⣿⣿⣿⣿⣷⢿⣿⣿⣿⣆⣼⠷⠛⠙⡛⠛⠒⠀⠀⠿⠿⠛⠉⠉⠀⠀⠴⠟⠉⢀⣠⣴⣤⠤⠤⠤⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿
⣼⣽⣿⣿⣿⠈⠛⠿⢿⡏⠀⣴⣟⢉⣹⠆⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠴⠚⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣏⣿
⢿⢻⣿⡟⠁⠀⠀⠀⢸⠀⠀⠈⠉⠛⠃⠀⠀⠀⠀⠛⣶⣄⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿
⣾⣾⣿⣧⠄⠀⠀⠀⠸⣄⣀⣀⣠⣶⣦⣤⣤⣤⡤⠞⡁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣏⣤⣿⣿⣧⣅⣿
⢿⣿⣿⣧⣴⠂⠀⠀⠀⠀⠉⠉⠁⠉⠻⠿⠿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣍⣿⣿⡿⣿⣿
⣿⣼⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣴⣾⣿⣿⣶⣿⣿⣿⣯⣭⣿⣿⣯⣿⣿
⡿⣿⣿⣿⣏⣤⣽⣿⣶⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠒⠛⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉
⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣹⣿⣿⣏⣀⣭⣿⣿⣀⣩⣿⣿⣅⣸⣿⣿⠤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠉⠉⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢦⡀⠀⠀⠉⠻⣿⣿⣽⣽⣿⡿⠛⢉⣾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣤⣤⣤⣤⣤⣀⣀
⠀⠈⠁⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⢼⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡏⠀⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣽⣿⣿⣿⣿⣿⣿
⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣷⠀⠀⠑⢤⣸⣦⣀⣀⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠻⢿⣿⣿⣿⣿
⣿⣿⣷⣶⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⡿⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠻⢿
⣏⣿⣿⣿⣿⣭⣿⣿⣷⣶⣦⣤⣤⢴⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣫⣽⣿⣿⣧⣀⣨⣿⣿⣮⣨⣿⣿⣄⣹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⡿⠿⠿⣿⡿⠿⢿⣿⡿⠿⢿⣿⡿⠿⠿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF

cat << EOF > /tmp/newjeans/coolwithyou.txt
₍ᐢ. .ᐢ₎ newjeans ୧ ‧₊˚
EOF

/usr/games/cowsay -f snowman "newjeans-getup" > /tmp/newjeans/getup.txt
/usr/games/cowsay -f stimpy "newjeans-ASAP" > /tmp/newjeans/asap.txt
