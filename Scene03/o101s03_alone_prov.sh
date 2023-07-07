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
apt-get install -y openssh-server parted xfsprogs
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
mkdir -p /srv/newjeans


mount /dev/sdb1 /mnt/ongojishin
mount /dev/sdb2 /opt/austin
mount -o noexec,async /dev/sdc1 /srv/newjeans

mkdir -p /tmp/o101s03/
mkdir -p /mnt/hybe/newjeans/
mkdir -p /tmp/o101s03/maze/{01..10}/{01..10}/{01..10}/{01..10}

# /tmp/o101s03/maze/01/01/02/03/ditto.txt

cat << EOF > /tmp/o101s03/maze/01/03/04/09/relative_path.sh
ls ../../06/07/../05/../../../01/02/03/ditto.txt 
ls ../01/../03/../../../04/../09/01/../02/hypeboy.txt
EOF

current_time=$(date +%s)

for i in {1..100}; do
    # Generate a random number of days, hours, minutes, and seconds
    rand_days=$((RANDOM % 365))
    rand_hours=$((RANDOM % 24))
    rand_minutes=$((RANDOM % 60))
    rand_seconds=$((RANDOM % 60))
    
    # Calculate the random timestamp by adding the random time intervals
    rand_timestamp=$((current_time + (rand_days * 24 * 60 * 60) + (rand_hours * 60 * 60) + (rand_minutes * 60) + rand_seconds))
    
    # Convert timestamp to date format
    rand_date=$(date -d "@$rand_timestamp" +'%Y-%m-%d %H:%M:%S')
    
    # Generate a random file name
    rand_filename="/tmp/o101s03/dummy_file_$i.txt"
    
    # Create the dummy file with random timestamp
    touch -d "$rand_date" "$rand_filename"
done