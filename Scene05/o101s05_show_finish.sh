#!/bin/bash

# Author: Daewon Kim
# Copyright 2023 Daewon Kim (prudentcircle@smsolutions.co.kr)
# This script deletes all Virtual Machines and volumes needed for Scene05 of OGJS-101.
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

INSTANCE="o101s05-show"
NETWORK="o101-net"
STORAGE="default"
INSTANCE_COUNT=2
TYPE="Container"
VOLUME_COUNT=0
PROVISION_SCRIPT="https://raw.githubusercontent.com/olchiyo/ogjs-101/main/Scene05/o101s05_show_prov.sh"
DNAT_PORT=10105



function delete_instance()
{
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
    then
        echo "$INSTANCE Instance exists. DELETING..."
        lxc stop $INSTANCE --force
        lxc delete $INSTANCE --force
        delete_forward
    else
        echo "ERROR:: $INSTANCE is not present. Nothing to do. EXITING..."
        delete_volumes
        delete_forward
        exit 1
    fi

}

function delete_instances()
{
    for i in $(seq $INSTANCE_COUNT)
    do
        TARGET="$INSTANCE""0""$i"
        echo -e "[INFO]\tCheck if $TARGET exists..."
        lxc list | grep "$TARGET"
        if [ $? -eq 0 ];
        then
            echo -e "[INFO]\t$TARGET Instance exists. DELETING..."
            lxc stop $TARGET --force && sleep 1
            lxc delete $TARGET --force && sleep 1
            delete_forward
        else
            echo "ERROR:: $INSTANCE is not present. Nothing to do. EXITING..."
            delete_volumes
            delete_forward
            exit 1
        fi
        DNAT_PORT=$(( DNAT_PORT+1 ))
    done
}

}

function delete_volumes()
{
    for (( i=1; i<=$VOLUME_COUNT; i++ ))
    do
        VOLUME_NAME="$INSTANCE"-vol0"$i"
        lxc storage volume list $STORAGE | grep $VOLUME_NAME
        if [ $? -eq 0 ];
        then
            echo "$VOLUME_NAME exists. DELETING..."
            lxc storage volume delete $STORAGE $VOLUME_NAME
        else
            echo "ERROR:: $VOLUME_NAME does not exist. EXITING..."
        fi
    done
}

function delete_forward()
{
    lxc network forward port remove $NETWORK $DNAT_IP tcp $DNAT_PORT >> /dev/null
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

if [ $INSTANCE_COUNT -eq 1 ];
then
    delete_instance
elif (( 2 <= $INSTANCE_COUNT && $INSTANCE_COUNT <= 9));
then   
    delete_instances
fi