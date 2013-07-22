#!/bin/bash
#
#   Copyright 2013 CSIR Meraka HLT and Multilingual Speech Technologies (MuST) North-West University
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# Author: Neil Kleynhans
#
# Create the directory if it does not exist
#
set -eu

MINIMUM_NUM_ARGS=1
if [ $# -lt $MINIMUM_NUM_ARGS ]; then
    echo "Usage: $0 variable_name1:directory1 variable_name2:directory2 ...."
    echo "Create directories if they don't exist"
    echo "E.G"
    echo 'bash create_folders.sh DIR_SRC:$DIR_SRC DIR_EXP:$DIR_EXP'
    exit 1
fi

# Cycle through arguments and create directories if necessary
RET_VAL=0
for dir_full in "$@"; do
    dir_name=`echo $dir_full | awk -F':' {'print $1'}`
    dir_value=`echo $dir_full | awk -F':' {'print $2'}`

    if [ ! -d $dir_value ]; then
        echo "INFO ($0): Creating directory - ($dir_name) $dir_value"
        mkdir -p $dir_value
        if [ $? -ne 0 ]; then
            echo "ERROR ($0): Failed to create ($dir_name) $dir_value" 1>&2
            RET_VAL=1
        fi
    else
        echo "INFO ($0): Directory ($dir_name) $dir_value exists. Moving on."
    fi
done

# 0 on success or error occurred
exit $RET_VAL

