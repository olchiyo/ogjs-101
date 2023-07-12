#!/bin/bash

# Author: Daewon Kim
# Copyright 2023 Daewon Kim (prudentcircle@smsolutions.co.kr)
# This script deletes all instances and volumes used for Scene03 of OGJS-101.
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

INSTANCE="o101s03-alone"
NETWORK="o101-net"
STORAGE="default"
VOLUME_COUNT=2
DNAT_PORT=10103



function delete_instance()
{
    lxc list | grep $INSTANCE
    if [ $? -eq 0 ];
    then
        echo "$INSTANCE VM exists. DELETING..."
        lxc stop $INSTANCE --force
        lxc delete $INSTANCE --force
    else
        echo "ERROR:: $INSTANCE is not present. Nothing to do. EXITING..."
        delete_volumes
        exit 1
    fi

}

function delete_volumes()
{
    for (( i=1; i<=$VOLUME_COUNT; i++))
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
}

function delete_forward()
{
    lxc network forward port remove $NETWORK $DNAT_IP tcp $DNAT_PORT
}

delete_instance
delete_volumes
delete_forward
