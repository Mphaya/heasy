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
# This script will call others scripts to perform basic cleanup of
# transcriptions as may be required for ASR. Ideally, this script should be run
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
EXPECTED_NUM_ARGS=2
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./PREPROC.sh <list> <option>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<list>"     "- text file, with two FULL PATHS per line: <file in> <file out>"

  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<option>  " "- customize preprocessing:"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "   " "- all_phases" "Perform all available preprocessing"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "   " "- lowercase" "Converts all text to lowercase"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "   " "- punctuation" "Removes punctuation specified (set FILE_PUNCT in Vars.sh)"

  exit $E_BAD_ARGS
fi

LIST=$1
FLAG=$2

#============================================================
# Some Basic checks
#============================================================
if [ ! -d $DIR_SRC ]; then
  echo -e "ERROR: Please set <DIR_SRC> in Vars.sh to valid directory"
  exit 1 
fi

if [ $FLAG = 'punctuation' ] || [ $FLAG = 'all_phases' ]; then
  if [ ! -s $FILE_PUNCT ]  || [ -z $FILE_PUNCT ]; then
    echo -e "ERROR: Please set <FILE_PUNCT> in Vars.sh to a valid filename"
    exit 1 
  fi
fi

#============================================================
# Start the preprocessing
#============================================================

TMP_LIST="$DIR_SCRATCH/tmp.lst"
if [ ! -d $DIR_SCRATCH ]; then
  mkdir $DIR_SCRATCH
fi
cp $LIST $TMP_LIST

if [ $FLAG = 'lowercase' ]   || [ $FLAG = 'all_phases' ]; then
  perl $DIR_SRC/lowercase.pl $TMP_LIST
  cat $TMP_LIST | awk {'print $2'} > $DIR_SCRATCH/1.lst
  paste $DIR_SCRATCH/1.lst $DIR_SCRATCH/1.lst > $TMP_LIST
fi

if [ $FLAG = 'punctuation' ] || [ $FLAG = 'all_phases' ]; then
  perl $DIR_SRC/remove_punctuation.pl $TMP_LIST $FILE_PUNCT
  cat $TMP_LIST | awk {'print $2'} > $DIR_SCRATCH/1.lst
  paste $DIR_SCRATCH/1.lst $DIR_SCRATCH/1.lst > $TMP_LIST
fi

rm $TMP_LIST
rm $DIR_SCRATCH/1.lst
