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

# Author: Charl van Heerdern (cvheerden@csir.co.za)
#
# Create a simple loop grammar for HVite
set -eu

EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./loop_grammar.sh <loop items>"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "loop items  " "- Text file with tokens that should be in your vocabulary (one item per line)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- $SENTSTART will be used as sentence start token, and $SENTEND as sentence end"
  exit 1
fi

LOCAL_LIST_TOKENS=$1

mkdir -p $DIR_EXP/models/grammar
HBuild -t $SENTSTART $SENTEND $LOCAL_LIST_TOKENS $GRAMMAR
