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
    if [$? -eq 0 ]
    then
        echo -e "It is confirmed that Storage "default" is in a running state"
    else
        echo -e "ERROR:: Storage "default" not in running state. EXITING..."
        exit 1
else 
    echo "ERROR:: Storage "default" does not exist EXITING..."
    exit 1
fi

lxc list | grep o101s03-alone
if [ $? -eq 0 ]
then
    echo "o101s03-alone VM already exists. DELETING..."
    lxc stop o101s03-alone --force && lxc delete o101s03 --force
else
    echo "o101s03-alone is not present. CREATING..."
    lxc launch images:debian/bookworm/default o101s03-alone --vm --network o101-net --storage default
    lxc list | grep o101s03-again
    
    if [ $? -eq 0 ]
    then
        echo -e "o101s03-alone successfully created."
    else
        echo "ERROR:: o101s03-alone not created. EXITING..."
        exit 1

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
else
    echo "o101s03-alone-vol01 is not present. CREATING..."
    lxc storage volume create default o101s03-alone-vol01 --type=block size=1073741824
    echo "Attaching o101s03-alone-vol01 to o101s03-alone..."
    lxc config device add o101s03-alone /dev/sdb disk pool=default source=o101s03-alone-vol01 
    echo "o101s03-alone-vol02 is not present. CREATING..."
    lxc storage volume create default o101s03-alone-vol02 --type=block size=1073741824
    echo "Attaching o101s03-alone-vol02 to o101s03-alone..."
    lxc config device add o101s03-alone /dev/sdc disk pool=default source=o101s03-alone-vol02 







