#!/bin/bash

# Author: Daewon Kim
# Copyright 2023 Daewon Kim (prudentcircle@smsolutions.co.kr)
# This script provisions an instance needed for Scene04 "보여줘김선임" of OGJS-101.
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
hostnamectl set-hostname o101s04-show
apt-get -y update
apt-get install -y openssh-server parted xfsprogs spell less python3-pip python3-full python3-venv
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

curl -L -O https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz
tar xvf ookla-speedtest-1.2.0-linux-aarch64.tgz
cp ./speedtest /usr/bin/

apt install

python3 -m venv o101s04-show
o101s04-show/bin/pip install faker


cat << EOF > o101s04_genfiles.py
from faker import Faker
fake = Faker()

with open("o101s04_csv.txt", mode="w") as f:
  for i in range(100):
    line = "{}\t{}\t{}\t{}\n".format(fake.name(), fake.email(), fake.latitude(), fake.longitude())
    f.write(line)
  f.close()

with open("o101s04_comma.txt", mode="w") as f:
  for i in range(100):
    line = "{},{},{},{},{}\n".format(fake.color_name(), fake.company(), fake.job(), fake.ssn(), fake.phone_number())
    f.write(line)
  f.close()

with open("o101s04_space.txt", mode="w") as f:
  for i in range(100):
    line = "{}\t{}\t{}\t{}\t{}\n".format(fake.color_name(), fake.company(), fake.job(), fake.ssn(), fake.phone_number())
    f.write(line)
  f.close()
EOF

o101s04-show/bin/python3 o101s04_genfiles.py