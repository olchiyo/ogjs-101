#!/bin/bash

# Author: Daewon Kim
# Copyright 2023 Daewon Kim (prudentcircle@smsolutions.co.kr)
# This script initilizes a Virtual Machine needed for Scene05 of OGJS-101.
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

INSTANCE="o101s05-try"
NETWORK="o101-net"
STORAGE="default"
INSTANCE_COUNT=2
TYPE="Container"
VOLUME_COUNT=0
PROVISION_SCRIPT=("https://raw.githubusercontent.com/olchiyo/ogjs-101/main/Scene05/o101s05_try_prov01.sh" "https://raw.githubusercontent.com/olchiyo/ogjs-101/main/Scene05/o101s05_try_prov02.sh")
DNAT_PORT=11105

function check_network()
{
    lxc network list | grep $NETWORK
    if [ $? -eq 0 ] 
    then 
        echo "[INFO] It is confirmed that Network $NETWORK exists"
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

function create_instance()
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

function create_instances()
{
    for i in $(seq $INSTANCE_COUNT)
    do
        TARGET="$INSTANCE""0""$i"
        echo -e "[INFO]\tCheck if $TARGET exists..."
        lxc list | grep "$TARGET"
        if [ $? -eq 0 ];
        then
            echo -e "[INFO]\t$TARGET Instance already exists. DELETING..."
            lxc stop $TARGET --force && sleep 1
            lxc delete $TARGET --force && sleep 1
            lxc network forward port remove $NETWORK $DNAT_IP tcp $DNAT_PORT 2> /dev/null
        fi

        if [[ "$TYPE" == "Container" ]];
        then
            echo -e "[INFO]\t$TARGET is not present. CREATING Containers..."
            lxc launch images:debian/bookworm/default $TARGET --network $NETWORK --storage $STORAGE
            provision_instance
        elif [[ "$TYPE" == "VM" ]];
        then
            echo -e "[INFO]\t$TARGET is not present. CREATING VMs..."
            lxc launch images:debian/bookworm/default $TARGET --vm --network $NETWORK --storage $STORAGE
            provision_instance
        fi

        DNAT_PORT=$(( DNAT_PORT+1 ))
    done
}

function provision_instance()
{

    lxc exec $TARGET -- bash -c "echo 'deb http://ftp.kr.debian.org/debian bookworm main' > /etc/apt/sources.list.d/korea.list && echo 'deb http://ftp.kr.debian.org/debian bookworm-updates main' >> /etc/apt/sources.list.d/korea.list && echo 'deb http://ftp.kr.debian.org/debian-security/ bookworm-security main' >> /etc/apt/sources.list.d/korea.list && sed -i 's/^\([^#]\)/#\1/g' /etc/apt/sources.list"
    lxc exec $TARGET -- bash -c "apt-get update -y && apt-get install -y curl"
    lxc exec $TARGET -- bash -c "curl -fsSL -H 'Cache-Control: no-cache, no-store' ${PROVISION_SCRIPT[$(( i-1 ))]} | bash"

    VM_IP=$(lxc list | grep $TARGET | awk '{print $6}')

    lxc network forward list $NETWORK | grep $DNAT_IP

    if [ $? -eq 1 ]
    then
        lxc network forward create $NETWORK $DNAT_IP
        lxc network forward port add $NETWORK $DNAT_IP tcp $DNAT_PORT $VM_IP 22
    else
        lxc network forward port remove $NETWORK $DNAT_IP tcp $DNAT_PORT 2> /dev/null
        lxc network forward port add $NETWORK $DNAT_IP tcp $DNAT_PORT $VM_IP 22 2> /dev/null
    fi

    echo "Enter the following Command to connect to $TARGET --"
    printf 'ssh -p %s root@%s\n' "$DNAT_PORT" "$DNAT_IP"

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
                echo -e "$VOLUME_NAME already exists. DELETING..."
                lxc storage volume delete $STORAGE $VOLUME_NAME
                lxc storage volume create $STORAGE $VOLUME_NAME --type=block size=1073741824
                echo "Attaching $VOLUME_NAME to $INSTANCE..."
                lxc config device add $INSTANCE $VOLUME_NAME disk pool=$STORAGE source=$VOLUME_NAME
            else
                echo -e "Volume $VOLUME_NAME does not exist. CREATING..."
                                lxc storage volume create $STORAGE $VOLUME_NAME --type=block size=1073741824
                echo -e "Attaching $VOLUME_NAME to $INSTANCE..."
                lxc config device add $INSTANCE $VOLUME_NAME disk pool=$STORAGE source=$VOLUME_NAME
            fi

        done
    else
        echo -e "[ERROR]\t$INSTANCE not created. EXITING..."
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
echo " " > ~/.ssh/known_hosts


if [ $INSTANCE_COUNT -eq 1 ];
then
    create_instance
elif (( 2 <= $INSTANCE_COUNT && $INSTANCE_COUNT <= 9));
then   
    create_instances
fi
