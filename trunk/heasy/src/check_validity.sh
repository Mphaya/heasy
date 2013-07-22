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
# Check validity of files, directories or variables
#
set -u

MINIMUM_NUM_ARGS=2
if [ $# -lt $MINIMUM_NUM_ARGS ]; then
    echo "Usage: $0 <-f | -d | -v> value1_name:value1 value2_name:value2 ..."
    echo -e "\t-f : Check if the specified files exist, are regular and are not zero length in size - or"
    echo -e "\t-d : Check if the specified directories exist and are indeed directories - or"
    echo -e "\t-v : Check if the specified variables are valid."
    echo -e ""
    echo -e "\tE.G."
    echo -e '\tbash check_validity.sh -d DIR_SRC:$DIR_SRC DIR_EXP:$DIR_EXP'
    echo -e '\tbash check_validity.sh -f AUDIO_TRN:$AUDIO_TRN'
    exit 1
fi

# Parse command line parameters
TASK=""
while getopts ":fdv" opt; do
   case $opt in
   f)
        if [ ! -z $TASK ]; then
            echo "ERROR ($0): TASK=$TASK already now trying to set it to 'FILE'! Only specify one argument: -f or -d or -v" 1>&2
            exit 1
        fi
        TASK="FILE"
   ;;
   d)
        if [ ! -z $TASK ]; then
            echo "ERROR ($0): TASK=$TASK already now trying to set it to 'DIR'! Only specify one argument: -f or -d or -v" 1>&2
            exit 1
        fi
        TASK="DIR"
   ;;
   v)
        if [ ! -z $TASK ]; then
            echo "ERROR ($0): TASK=$TASK already now trying to set it to 'VAR'! Only specify one argument: -f or -d or -v" 1>&2
            exit 1
        fi
        TASK="VAR"
   ;;
   \?)
        echo "ERROR ($0): Invalid option -$OPTARG" 1>&2
        exit 1
   ;;
   esac
done
shift $(($OPTIND - 1))

# TASK not set
if [ -z $TASK ]; then
    echo "ERROR ($0): One of the following command line arguments must be set: -f or -d or -v" 1>&2
    exit 1
fi

# cycle through command line arguments and perform checks
exit_status=0
case "$TASK" in
    # Check file case
    FILE )
        for file_full in "$@"; do
            file_name=`echo $file_full | awk -F':' {'print $1'}`
            file_value=`echo $file_full | awk -F':' {'print $2'}`
            file_value=`readlink -n -e $file_value`
            FLAG=0
            # Does it exist
            if [ ! -e $file_value ]; then
                exit_status=1
                FLAG=1
                echo "ERROR ($0): File ($file_name) $file_value does not exist!" 1>&2
            fi
            # Is is a regular file
            if [ ! -f $file_value ]; then
                exit_status=1
                FLAG=1
                echo "ERROR ($0): File ($file_name) $file_value is not a regular file!" 1>&2
            fi
            # Is it 0 bytes in size
            if [ ! -s $file_value ]; then
                exit_status=1
                FLAG=1
                echo "ERROR ($0): File ($file_name) $file_value is empty!" 1>&2
            fi
            # All tests passed
            if [ $FLAG -eq "0" ]; then
                echo "INFO ($0): File ($file_name) $file_value is OK"
            fi
        done
    ;;
    # Check directory case
    DIR )
        for dir_full in "$@"; do
            dir_name=`echo $dir_full | awk -F':' {'print $1'}`
            dir_value=`echo $dir_full | awk -F':' {'print $2'}`
            dir_value=`readlink -n -e $dir_value`
            FLAG=0
            # Does it exist
            if [ ! -e $dir_value ]; then
                exit_status=1
                FLAG=1
                echo "ERROR ($0): Directory ($dir_name) $dir_value does not exist!" 1>&2
            fi
            # Is it a directory
            if [ ! -d $dir_value ]; then
                exit_status=1
                FLAG=1
                echo "ERROR ($0): ($dir_name) $dir_value is not a directory!" 1>&2
            fi
            # All tests passed
            if [ $FLAG -eq "0" ]; then
                echo "INFO ($0): Directory ($dir_name) $dir_value is OK"
            fi
        done
    ;;
    # Check variable case
    VAR )
        for var_full in "$@"; do
            var_name=`echo $var_full | awk -F':' {'print $1'}`
            var_value=`echo $var_full | awk -F':' {'print $2'}`
            FLAG=0
            # Is it a null (empty) string
            if [ -z $var_value ]; then
                exit_status=1
                FLAG=1
                echo "ERROR ($0): Variable ($var_name) $var_value is empty!" 1>&2
            fi
            # All tests passed
            if [ $FLAG -eq "0" ]; then
                echo "INFO ($0): Variable ($var_name) $var_value is OK"
            fi
        done
    ;;
esac

# O on success else error occurred
exit $exit_status

