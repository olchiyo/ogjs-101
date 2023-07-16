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

INSTANCE="o101s04-alone"
NETWORK="o101-net"
STORAGE="default"
VOLUME_COUNT=2
PROVISION_SCRIPT="https://raw.githubusercontent.com/olchiyo/ogjs-101/main/Scene04/o101s04_alone_prov.sh"
DNAT_PORT=10104

function check_network()
{
    lxc network list | grep $NETWORK
    if [ $? -eq 0 ] 
    then 
        echo "It is confirmed that Network $NETWORK exists"
    else 
        echo "[ERROR] $NETWORK does not exist. EXITING..."
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
            echo -e "[INFO] It is confirmed that Storage $STORAGE is in a running state"
        else
            echo -e "[ERROR] Storage $STORAGE not in running state. EXITING..."
            exit 1
        fi
    else 
        echo "[ERROR] Storage $STORAGE does not exist EXITING..."
        exit 1
    fi
}

function create_instance_vm()
{
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
then
    echo "$INSTANCE VM already exists. DELETING..."
    lxc stop $INSTANCE --force && sleep 1
    lxc delete $INSTANCE --force && sleep 1
    lxc launch images:debian/bookworm/default $INSTANCE --vm --network $NETWORK --storage $STORAGE
    sleep 5
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
    then
        echo "$INSTANCE successfully created."
    else
        echo "[ERROR] $INSTANCE not created. EXITING..."
        exit 1
    fi
else
    sleep 2
    echo "$INSTANCE is not present. CREATING..."
    lxc launch images:debian/bookworm/default $INSTANCE --vm --network $NETWORK --storage $STORAGE
    sleep 5
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
    then
        echo "$INSTANCE successfully created."
    else
        echo "[ERROR] $INSTANCE not created. EXITING..."
        exit 1
    fi
fi
}

function create_instance_lxc()
{
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
then
    echo "$INSTANCE VM already exists. DELETING..."
    lxc stop $INSTANCE --force && sleep 1
    lxc delete $INSTANCE --force && sleep 1
    lxc launch images:debian/bookworm/default $INSTANCE --network $NETWORK --storage $STORAGE
    sleep 5
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
    then
        echo "$INSTANCE successfully created."
    else
        echo "[ERROR] $INSTANCE not created. EXITING..."
        exit 1
    fi
else
    sleep 2
    echo "$INSTANCE is not present. CREATING..."
    lxc launch images:debian/bookworm/default $INSTANCE --network $NETWORK --storage $STORAGE
    sleep 5
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
    then
        echo "$INSTANCE successfully created."
    else
        echo "[ERROR] $INSTANCE not created. EXITING..."
        exit 1
    fi
fi
}


function create_volumes()
{
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
    then
        for (( i=1; i <=$VOLUME_COUNT; i++ ))
        do
            VOLUME_NAME="$INSTANCE"-vol0"$i"
            lxc storage volume list $STORAGE | grep $VOLUME_NAME
            if [ $? -eq 0 ];
            then
                echo "$VOLUME_NAME already exists. DELETING..."
                lxc storage volume delete $STORAGE $VOLUME_NAME
                lxc storage volume create $STORAGE $VOLUME_NAME --type=block size=1073741824
                echo "Attaching $VOLUME_NAME to $INSTANCE..."
                lxc config device add $INSTANCE $VOLUME_NAME disk pool=$STORAGE source=$VOLUME_NAME
            else
                echo "Volume $VOLUME_NAME does not exist. CREATING..."
                                lxc storage volume create $STORAGE $VOLUME_NAME --type=block size=1073741824
                echo "Attaching $VOLUME_NAME to $INSTANCE..."
                lxc config device add $INSTANCE $VOLUME_NAME disk pool=$STORAGE source=$VOLUME_NAME
            fi

        done
    else
        echo "[ERROR] $INSTANCE not created. EXITING..."
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
create_instance_lxc
echo " " > ~/.ssh/known_hosts

## Basic Provisioning

lxc exec $INSTANCE -- ls 2> /dev/null || EXIT_CODE=$?
while ! lxc exec $INSTANCE -- 'ls' 2> /dev/null
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
    lxc network forward port remove $NETWORK $DNAT_IP tcp $DNAT_PORT
    lxc network forward port add $NETWORK $DNAT_IP tcp $DNAT_PORT $VM_IP 22
fi

echo "Enter the following Command to connect to $INSTANCE --"
printf 'ssh -p %s root@%s\n' "$DNAT_PORT" "$DNAT_IP"

