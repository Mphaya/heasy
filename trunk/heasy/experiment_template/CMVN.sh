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
# This script allows you to do cepstral mean and or variance normalization on
# clusters of speakers (cluster determined by a mask you have to specify)
#
# IMPORTANT:
#  - only works for MFCCs (assumes 39 dimensional output)
#  - set ALL variables under CMVN in Vars.sh
#  - Make sure your list file is correct. The second "file" specified on each
#    line will be altered permanently, and in this case quite a few times,
#    depending on what kind of normalization will be performed
#  - Make sure to set the DIR_SRC variable in Vars.sh to point to where the
#    extracted source files are located.
set -eu
source Vars.sh

#============================================================
# Check that the number of arguments are correct
#============================================================
EXPECTED_NUM_ARGS=2
E_BAD_ARGS=65

if [ $# -lt $EXPECTED_NUM_ARGS ]; then
	echo "Usage: ./CMVN.sh <option> <list> (+ you HAVE to set the variables under CMVN in Vars.sh)"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<option>" "customize training:"
  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "cmn" "- perform only cepstral mean normalization"
  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "cvn" "- perform only cepstral variance normalization"
  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "cmvn" "- perform cepstral mean and variance normalization"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<list>" "text file, with two FULL PATHS per line: <file in> <file out>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "      " "<file in>  - should be an audio file (probably wav)"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "      " "<file out> - should be an mfc file that will be created"

  exit $E_BAD_ARGS
fi

FLAG=$1
LIST=$2

#============================================================
# Some Basic checks and setup
#============================================================
if [ ! -s $LIST ]; then
  echo -e "ERROR: LIST <$LIST> does not exist!"
  exit $E_BAD_ARGS
fi

if [ ! -d $DIR_SRC ]; then
  echo -e "ERROR: Please set $bold_begin DIR_SRC $bold_end in Vars.sh to valid directory"
  exit $E_BAD_ARGS
fi

#TODO: Proper DIR_LOG var needed
if [ ! -d $DIR_EXP/log ]; then
  echo -e "WARNING: Creating $DIR_EXP/log"
  mkdir -p $DIR_EXP/log
fi

if [ ! -d $DIR_SCRATCH ]; then
  echo -e "WARNING: Creating <DIR_SCRATCH> in Vars.sh"
  mkdir -p $DIR_SCRATCH
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create $DIR_SCRATCH. Exiting!"
    exit 1;
  fi
fi

# Normalization Process:
# (1)	Extract features without normalization
# (2)	Estimate the cluster means and variances (if cmvn, variance clusters are estimated after mean normalization)
# (3)	Extract the features again, this time doing normalization given the cluster means and/or variances

#============================================================
# CMN & FIRST STEP OF CMVN
#============================================================
if [ $FLAG = 'cmn' ] || [ $FLAG = 'cmvn' ]; then
  bash $DIR_SRC/cmn.sh $FLAG $LIST 2>&1 | tee -a $DIR_EXP/log/cmn.log
  if [ $? -ne 0 ]; then
    echo "ERROR: $FLAG failed for some reason. Please check the logs!"
    exit 1;
  fi
fi

#============================================================
# CVN & SECOND STEP OF CMVN
#============================================================
if [ $FLAG = 'cvn' ] || [ $FLAG = 'cmvn' ]; then
  bash $DIR_SRC/cvn.sh $FLAG $LIST 2>&1 | tee -a $DIR_EXP/log/cvn.log
  if [ $? -ne 0 ]; then
    echo "ERROR: $FLAG failed for some reason. Please check the logs!"
    exit 1;
  fi
fi
