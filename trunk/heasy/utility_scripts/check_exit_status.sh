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

# Author: Neil Kleynhans (ntkleynhans@csir.co.za)
set -eu

EXPECTED_NUM_ARGS=2
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./check_exit_status.sh program_name exit_status"
  exit $E_BAD_ARGS
fi

PROG_NAME=$1
EXIT_CODE=$2

# Check exit code
if [ "$EXIT_CODE" -ne "0" ]; then
    echo "ERROR ($EXIT_CODE): A command in $PROG_NAME did not exit correctly. Please check the log file" #TODO: must determine log file
    exit $EXIT_CODE
fi

