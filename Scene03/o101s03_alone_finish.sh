#!/bin/bash

# Author: Daewon Kim
# Copyright 2023 Daewon Kim (prudentcircle@smsolutions.co.kr)
# This script deletes all Virtual Machines and volumes needed for Scene03 of OGJS-101.
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


lxc list | grep o101s03-alone
if [ $? -eq 0 ]
then
    echo "o101s03-alone VM exists. DELETING..."
    lxc stop o101s03-alone --force && lxc delete o101s03 --force
else
    echo "ERROR:: o101s03-alone is not present. Nothing to do. EXITING..."
    exit 1

lxc storage volume list default | grep o101s03-alone-vol01
if [ $? -eq 0 ]
then
    echo "o101s03-alone-vol01 exists. DELETING..."
    lxc storage volume delete default o101s03-alone-vol01
else
    echo "o101s03-alone-vol01 is not present. Nothing to do. EXITING..."
    exit 1

lxc storage volume list default | grep o101s03-alone-vol02
if [ $? -eq 0 ]
then
    echo "o101s03-alone-vol01 exists. DELETING..."
    lxc storage volume delete default o101s03-alone-vol01
else
    echo "o101s03-alone-vol01 is not present. Nothing to do. EXITING..."
    exit 1
