#!/bin/bash

# Author: Daewon Kim
# Copyright 2023 Daewon Kim (prudentcircle@smsolutions.co.kr)
# This script provisions a Virtual Machine needed for Scene03 of OGJS-101.
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
apt-get -y update
apt-get install -y openssh-server
sed -i '/^PermitRootLogin/d' /etc/ssh/sshd_config
bash -c 'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config'
systemctl restart ssh

parted --script /dev/sdb \
    mklabel msdos \
    mkpart primary ext4 1MiB 300MiB \
    mkpart primary xfs 300MiB 800MiB

parted --script /dev/sdc \
    mklabel msdos \
    mkpart primary ext3 0% 20% \
    mkpart primary xfs 20% 60%

mkfs.ext4 /dev/sdb1
mkfs.xfs /dev/sdb2
mkfs.ext3 /dev/sdc1

mkdir -p /mnt/ongojishin
mkdir -p /opt/austin
mkdir -p /svr/newjeans


mount /dev/sdb1 /mnt/ongojishin
mount /dev/sdb2 /opt/austin
mount /dev/sdc1 /srv/newjeans