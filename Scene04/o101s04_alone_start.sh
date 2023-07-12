#!/bin/bash

# Author: Daewon Kim
# Copyright 2023 Daewon Kim (prudentcircle@smsolutions.co.kr)
# This script initilizes a Virtual Machine needed for Scene04 of OGJS-101.
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

DNAT_IP=""
INSTANCE="o101s04-alone"
NETWORK="o101-net"
STORAGE="default"
VOLUME_COUNT=1
PROVISION_SCRIPT="https://raw.githubusercontent.com/olchiyo/ogjs-101/main/Scene03/o101s03_alone_prov.sh"
DNAT_PORT=10103

function check_network()
{
    lxc network list | grep $NETWORK
    if [ $? -eq 0 ] 
    then 
        echo "It is confirmed that Network $NETWORK exists"
    else 
        echo "[ERROR] o101-net does not exist. EXITING..."
        exit 1
    fi
}

function check_storage()
{
    lxc storage list | grep $STORAGE
    if [ $? -eq 0 ];
    then 
        echo "It is confirmed that Storage $STORAGE exists"
        lxc storage list | grep CREATED
        if [ $? -eq 0 ]
        then
            echo -e "It is confirmed that Storage $STORAGE is in a running state"
        else
            echo -e "ERROR:: Storage $STORAGE not in running state. EXITING..."
            exit 1
        fi
    else 
        echo "ERROR:: Storage $STORAGE does not exist EXITING..."
        exit 1
    fi
}

function create_instance()
{
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
then
    echo "o101s03-alone VM already exists. DELETING..."
    lxc stop o101s03-alone --force && sleep 2
    lxc delete o101s03-alone --force && sleep 2
    lxc launch images:debian/bookworm/default $INSTANCE --vm --network $NETWORK --storage $STORAGE
    sleep 5
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
    then
        echo "$INSTANCE successfully created."
    else
        echo "ERROR:: $INSTANCE not created. EXITING..."
        exit 1
    fi
else
    sleep 2
    echo "$INSTANCE is not present. CREATING..."
    lxc launch images:debian/bookworm/default $INSTANCE --vm --network $NETWORK --storage $STORAGE
    sleep 5
    lxc list | grep o101s03-alone
    if [ $? -eq 0 ];
    then
        echo "o101s03-alone successfully created."
    else
        echo "ERROR:: o101s03-alone not created. EXITING..."
        exit 1
    fi
fi
}

function create_volumes()
{
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
        for (( i=1; i<=$VOLUME_NUM; i++s))
        do
            VOLUME_NAME="$INSTANCE"-vol0"$i"
            lxc storage volume list $STORAGE | grep $VOLUME_NAME
            if [ $? -eq 0 ]
                echo "$VOLUME_NAME already exists. DELETING..."
                lxc storage volume delete $STORAGE $VOLUME_NAME
                lxc storage volume create $STORAGE $VOLUME_NAME --type=block size=1073741824
                echo "Attaching $VOLUME_NAME to $INSTANCE..."
                lxc config device add $INSTANCE $VOLUME_NAME disk pool=$STORAGE source=$VOLUME_NAME
            fi
    else
        echo "ERROR:: $INSTANCE not created. EXITING..."
        exit 1
    fi
}


if [ -z $DNAT_IP ]; 
then
    echo "please run command below and run the command again"
    echo "export DNAT_IP=<Your DNAT IP>"
    exit 1
fi

if [[ $DNAT_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "success"
else
  echo "ERROR:: Wrong IP Address"
  exit 1
fi

check_network
check_storage
create_instance
create_volumes

## Basic Provisioning

lxc exec $INSTANCE -- ls || EXIT_CODE=$?
while ! lxc exec $INSTANCE -- ls
do
    sleep 2
done

echo -e "Now, provisioning $INSTANCE"

lxc exec $INSTANCE -- bash -c "echo 'deb http://ftp.kr.debian.org/debian bookworm main' > /etc/apt/sources.list.d/korea.list && echo 'deb http://ftp.kr.debian.org/debian bookworm-updates main' >> /etc/apt/sources.list.d/korea.list && echo 'deb http://ftp.kr.debian.org/debian-security/ bookworm-security main' >> /etc/apt/sources.list.d/korea.list && sed -i 's/^\([^#]\)/#\1/g' /etc/apt/sources.list"
lxc exec $INSTANCE -- bash -c "apt-get update -y && apt-get install -y curl"
lxc exec $INSTANCE -- bash -c "curl -fsSL -H 'Cache-Control: no-cache, no-store' $PROVISION_SCRIPT | bash"

VM_IP=$(lxc list | grep $INSTANCE | awk '{print $6}')

lxc network forward list $NETWORK | grep $DNAT_IP
if [ $? -eq 1 ]
then
    lxc network forward create $NETWORK $DNAT_IP
    lxc network forward port add $NETWORK $DNAT_IP tcp $DNAT_PORT $VM_IP 22
else
    lxc network forward port add $NETWORK $DNAT_IP tcp $DNAT_PORT $VM_IP 22
fi

echo "Enter the following Command to connect to $INSTANCE --"
printf 'ssh -p %s root@%s\n' "$DNAT_PORTs" "$DNAT_IP"

