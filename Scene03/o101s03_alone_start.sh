#!/bin/bash

# Author: Daewon Kim
# Copyright 2023 Daewon Kim (prudentcircle@smsolutions.co.kr)
# This script initilizes a Virtual Machine needed for Scene03 of OGJS-101.
# Designed to run on pre-configured ODROID-M1 machines ONLY.
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

if [ -z $DNAT_IP ]; 
then
    echo "please run command below and run the command again"
    echo "export DNAT_IP=<Your DNAT IP>"
    exit 1
done

if [[ $DNAT_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "success"
else
  echo "ERROR:: Wrong IP Address"
  exit 1
fi



lxc network list | grep o101-net
if [ $? -eq 0 ] 
then 
    echo "It is confirmed that Network o101-net exists"
else 
    echo "ERROR:: o101-net does not exist. EXITING..."
    exit 1
fi

lxc storage list | grep default
if [ $? -eq 0 ] 
then 
    echo "It is confirmed that Storage "default" exists"
    lxc storage list | grep CREATED
    if [ $? -eq 0 ]
    then
        echo -e "It is confirmed that Storage "default" is in a running state"
    else
        echo -e "ERROR:: Storage "default" not in running state. EXITING..."
        exit 1
    fi
else 
    echo "ERROR:: Storage "default" does not exist EXITING..."
    exit 1
fi

lxc list | grep o101s03-alone
if [ $? -eq 0 ]
then
    echo "o101s03-alone VM already exists. DELETING..."
    lxc stop o101s03-alone --force
    lxc delete o101s03-alone --force
    lxc launch images:debian/bookworm/default o101s03-alone --vm --network o101-net --storage default
    sleep 5
    lxc list | grep o101s03-alone
    if [ $? -eq 0 ]
    then
        echo -e "o101s03-alone successfully created."
    else
        echo "ERROR:: o101s03-alone not created. EXITING..."
        exit 1
    fi
else
    echo "o101s03-alone is not present. CREATING..."
    lxc launch images:debian/bookworm/default o101s03-alone --vm --network o101-net --storage default
    sleep 5
    lxc list | grep o101s03-alone
    if [ $? -eq 0 ]
    then
        echo -e "o101s03-alone successfully created."
    else
        echo "ERROR:: o101s03-alone not created. EXITING..."
        exit 1
    fi
fi

lxc storage volume list default | grep o101s03-alone-vol01
if [ $? -eq 0 ]
then
    echo "o101s03-alone VM already exists. DELETING..."
    lxc storage volume delete default o101s03-alone-vol01
    echo "Now, creating o101s03-alone-vol01..."
    lxc storage volume create default o101s03-alone-vol01 --type=block size=1073741824
    echo "Attaching o101s03-alone-vol01 to o101s03-alone..."
    lxc config device add o101s03-alone /dev/sdb disk pool=default source=o101s03-alone-vol01 
    lxc storage volume list default | grep o101s03-alone-vol02
    if [ $? -eq 0 ]
    then
        echo "o101s03-alone-vol02 already exists. DELETING..."
        lxc storage volume delete default o101s03-alone-vol02
        echo "o101s03-alone-vol02 is not present now. CREATING..."
        lxc storage volume create default o101s03-alone-vol02 --type=block size=1073741824
        echo "Attaching o101s03-alone-vol02 to o101s03-alone..."
        lxc config device add o101s03-alone /dev/sdc disk pool=default source=o101s03-alone-vol02
    else
        echo "o101s03-alone-vol02 is not present. CREATING..."
        lxc storage volume create default o101s03-alone-vol02 --type=block size=1073741824
        echo "Attaching o101s03-alone-vol02 to o101s03-alone..."
        lxc config device add o101s03-alone /dev/sdc disk pool=default source=o101s03-alone-vol02 
    fi
else
    echo "o101s03-alone-vol01 is not present. CREATING..."
    lxc storage volume create default o101s03-alone-vol01 --type=block size=1073741824
    echo "Attaching o101s03-alone-vol01 to o101s03-alone..."
    lxc config device add o101s03-alone /dev/sdb disk pool=default source=o101s03-alone-vol01 
    echo "o101s03-alone-vol02 is not present. CREATING..."
    lxc storage volume create default o101s03-alone-vol02 --type=block size=1073741824
    echo "Attaching o101s03-alone-vol02 to o101s03-alone..."
    lxc config device add o101s03-alone /dev/sdc disk pool=default source=o101s03-alone-vol02
fi

lxc exec o101s03-alone -- ls || EXIT_CODE=$?
while ! lxc exec o101s03-alone -- ls
do
    sleep 2
done

echo -e "Now, provisioning o101s03-alone"

lxc exec o101s03-alone -- bash -c "echo 'deb http://ftp.kr.debian.org/debian bookworm main' > /etc/apt/sources.list.d/korea.list && echo 'deb http://ftp.kr.debian.org/debian bookworm-updates main' >> /etc/apt/sources.list.d/korea.list && echo 'deb http://ftp.kr.debian.org/debian-security/ bookworm-security main' >> /etc/apt/sources.list.d/korea.list && sed -i 's/^\([^#]\)/#\1/g' /etc/apt/sources.list"
lxc exec o101s03-alone -- bash -c "apt-get update -y && apt-get install -y curl"
lxc exec o101s03-alone -- bash -c "curl -fsSL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/olchiyo/ogjs-101/main/Scene03/o101s03_alone_prov.sh | bash"

VM_IP=$(lxc list | grep o101s03-alone | awk '{print $6}')

lxc network forward list o101-net | grep $DNAT_IP
if [ $? -eq 1 ]
then
    lxc network forward create o101-net $DNAT_IP
    lxc network forward port add o101-net $DNAT_IP tcp 10022 $VM_IP 22
else
    lxc network forward port add o101-net $DNAT_IP tcp 10022 $VM_IP 22
fi

echo "Enter the following Command to connect to o101s03-alone --"
printf 'ssh -p 10022 root@%s\n' "$DNAT_IP"

