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
# Author: Charl van Heerden (cvheerden@csir.co.za)
# 
# This script will call others scripts to extract features from
# specified audio files.Ideally, this script should be run
# only once per corpus. See the flag options for more details.
#
# IMPORTANT:
#  - Make sure your list file is correct. The second "file" specified on each
#    line will be altered permanently.
#  - Make sure to set the DIR_SRC variable in Vars.sh to point to where the
#    extracted source files are located.
set -eu
source Vars.sh

#============================================================
# Check that the number of arguments are correct
#============================================================
EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -lt $EXPECTED_NUM_ARGS ]; then
	echo "Usage: ./FEATURE_EXTRACTION.sh <list> <config(optional)>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<list>" "text file, with two FULL PATHS per line: <file in> <file out>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<config>" "optional configuration file:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "if specified:" "It will be used :-) (we assume you know what you're doing...)"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "not specified:" "A default config file will be created as \$DIR_EXP/config (see Vars.sh), with TARGETKIND obtained from Vars.sh"

  exit $E_BAD_ARGS
fi

# Assign local variables
LIST=$1
CFG=""
if [ $# -eq 2 ]; then
   CFG=$2
fi

#============================================================
# Some Basic checks
#============================================================
if [ ! -z $CFG ] && [ ! -d $DIR_SRC ]; then
  echo -e "ERROR: Please set $bold_begin DIR_SRC $bold_end in Vars.sh to valid directory"
  exit 1 
fi

if [ -z $CFG ] && [ -z $TARGETKIND ] || [ ! -s $CFG ] && [ -z $TARGETKIND ]; then
  echo -e "ERROR: Please set $bold_begin TARGETKIND $bold_end in Vars.sh to a valid filename"
  exit 1 
fi

#============================================================
# Start the feature extraction
#============================================================

# If a config file isn't specified, generate one
if [ -z $CFG ] || [ ! -s $CFG ]; then
  echo "Generating a config file: TARGETKIND <$TARGETKIND>"
  CFG=$CFG_HCOPY
  # Make sure DIR_CFG exists, since init.sh might not have been run yet
  mkdir -p $DIR_EXP/config
  bash $DIR_SRC/create_configs.sh hcopy $CFG_HCOPY
fi

# Do feature extraction
HCopy -T $TRACE -C $CFG -S $LIST

