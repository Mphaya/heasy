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
# This script will call others scripts to perform phone or word recognition
# given a trained ASR system
#
# IMPORTANT:
#  - set ALL variables in Vars.sh
#  - make sure you have audio and transcription trn+tst lists
#  - make sure you have a valid pronunciation dictionary
#  - do ./CHECK.sh all_phases to test your setup
set -eu
source Vars.sh

#==============================================================================
# Check that the number of arguments are correct
#==============================================================================
EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./TEST.sh <flag>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<option>" "customize evaluation:"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "phone_rec       " "- Do phoneme recognition"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "word_rec_hvite  " "- Do word recognition using HTK"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "word_rec_juicer " "- Do word recognition using Juicer"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "phone_results   " "- Uses hresults to calculate accuracy"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "word_results    " "- Uses hresults to calculate accuracy"

  exit $E_BAD_ARGS
fi

FLAG=$1

#==============================================================================
# Some Basic checks
#==============================================================================
if [ ! -d $DIR_SRC ]; then
  echo -e "ERROR: Please set <DIR_SRC> in Vars.sh to valid directory"
  exit 1 
fi

if [ ! -d $DIR_EXP ]; then
  echo "ERROR: $DIR_EXP MUST exist. Exiting!"
  exit 1;
fi

#==============================================================================
# DO PHONE RECOGNITION
#==============================================================================
if [ $FLAG = 'phone_rec' ]; then
  echo "TEST: Starting phone recognition" 2>&1 | tee -a $DIR_LOG/phone_recognition.log
  bash $DIR_SRC/phone_recognition.sh >> $DIR_LOG/phone_recognition.log 2>> $DIR_LOG/phone_recognition.err
fi

#==============================================================================
# DO WORD RECOGNITION USING HVITE
#==============================================================================
if [ $FLAG = 'word_rec_hvite' ]; then
  echo "TEST: Starting word recognition using HTK" 2>&1 | tee -a $DIR_LOG/word_recognition.log
  bash $DIR_SRC/word_recognition.sh >> $DIR_LOG/word_recognition.log 2>> $DIR_LOG/word_recognition.err
fi

#==============================================================================
# DO WORD RECOGNITION USING JUICER
#==============================================================================
if [ $FLAG = 'word_rec_juicer' ]; then
  echo "TEST: Starting word recognition using Juicer" 2>&1 | tee -a $DIR_LOG/word_recognition_juicer.log
  bash $DIR_SRC/word_recognition_juicer.sh >> $DIR_LOG/word_recognition_juicer.log 2>> $DIR_LOG/word_recognition_juicer.err
fi

#==============================================================================
# PHONE HRESULTS
#==============================================================================
if [ $FLAG = 'phone_results' ]; then
  echo "TEST: Starting word recognition" 2>&1 | tee -a $DIR_LOG/phone_results.log
  HResults -A -D -T 1 -V -s -p -z sil -I $MLF_PHNS_TST $LIST_MONOPHNS $DIR_EXP/results/test_results.mlf >> $DIR_LOG/phone_results.log 2>> $DIR_LOG/phone_results.err
fi

#==============================================================================
# WORD HRESULTS (-p off, since conf matrix would be too large)
#==============================================================================
if [ $FLAG = 'word_results' ]; then
  echo "TEST: Starting word recognition" 2>&1 | tee -a $DIR_LOG/word_results.log
  HResults -A -D -T 1 -V -s -z sil -I $MLF_WORDS_TST $LIST_WORDS_TRN $DIR_EXP/results/test_results.mlf >> $DIR_LOG/word_results.log 2>> $DIR_LOG/word_results.err
fi
