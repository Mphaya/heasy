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
# This script will call others scripts to try to determine if your
# ASR setup is sufficient to run through.
#
# IMPORTANT:
#  - Make sure to set ALL variables under "REQUIRED" in Vars.sh
#  - Make sure all scripts under DIR_SRC are executables (cmod a+x)
set -eu
source Vars.sh

#============================================================
# Check that the number of arguments are correct
#============================================================
EXPECTED_NUM_ARGS=1
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: ./CHECK.sh <option>"
  printf "\n\t$bold_begin%-10s$bold_end%s\n" "<option>" "customize checking:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "all_phases  " "- Perform all checks"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "variables " "- Check that all expected variables are set"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "software  " "- Check that all expected software is available in the PATH"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "lists     " "- Check that all required lists exist. Will also check:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Every audio file has a transcription"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Every transcription has an audio file"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Every transcription has only one line of text"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- No empty transcriptions"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Check that every audio file is > 200 bytes"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "dicts     " "- Check that all words have a pronunciation: Will also check:"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- No empty pronunciations"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- No monophones with < 3 examples in lists"

  printf "\n\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "textformat" "- Check for text that may break HTK"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Checks phoneset for illegal characters"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "            " "- Checks transcriptions for illegal characters"
  exit $E_BAD_ARGS
fi

FLAG=$1

# These folders are always required. Make sure that they exist and create them if not.
bash $DIR_SRC/create_folders.sh "DIR_EXP:$DIR_EXP" "DIR_SCRATCH:$DIR_SCRATCH" "DIR_LOG:$DIR_LOG"

#============================================================
# Check required variables
#============================================================
if [ $FLAG = 'variables' ] || [ $FLAG = 'all_phases' ]; then
  if [ -z $DIR_SRC ] || [ ! -d $DIR_SRC ]; then
    echo "ERROR: DIR_SRC invalid (set it in Vars.sh)"
  fi

  bash $DIR_SRC/check_validity.sh -v "DIR_CFG:$DIR_CFG" "DIR_SCRATCH:$DIR_SCRATCH" "DIR_EXP:$DIR_EXP"
  bash $DIR_SRC/check_validity.sh -d "DIR_CFG:$DIR_CFG" "DIR_SCRATCH:$DIR_SCRATCH" "DIR_EXP:$DIR_EXP"

  bash $DIR_SRC/check_validity.sh -v "LST_AUDIO_TRN_ORIG:$LST_AUDIO_TRN_ORIG" "LST_AUDIO_TST_ORIG:$LST_AUDIO_TST_ORIG" "LST_TRANS_TRN_ORIG:$LST_TRANS_TRN_ORIG" "LST_TRANS_TST_ORIG:$LST_TRANS_TST_ORIG" "DICT:$DICT"
  bash $DIR_SRC/check_validity.sh -f "LST_AUDIO_TRN_ORIG:$LST_AUDIO_TRN_ORIG" "LST_AUDIO_TST_ORIG:$LST_AUDIO_TST_ORIG" "LST_TRANS_TRN_ORIG:$LST_TRANS_TRN_ORIG" "LST_TRANS_TST_ORIG:$LST_TRANS_TST_ORIG" "DICT:$DICT"
fi

#============================================================
# Check required software
#============================================================
if [ $FLAG = 'software' ] || [ $FLAG = 'all_phases' ]; then
    bash $DIR_SRC/check_software.sh $DIR_SRC
fi

#============================================================
# Check required lists
#============================================================
if [ $FLAG = 'lists' ] || [ $FLAG = 'all_phases' ]; then
  # Check (a), (b)
  perl $DIR_SRC/check_every_audio_has_text_and_vv.pl $LST_AUDIO_TRN_ORIG $LST_TRANS_TRN_ORIG
  perl $DIR_SRC/check_every_audio_has_text_and_vv.pl $LST_AUDIO_TST_ORIG $LST_TRANS_TST_ORIG

  # Check that transcripts have content (and only one line per file)
  perl $DIR_SRC/check_transcripts_have_content.pl $LST_TRANS_TRN_ORIG
  perl $DIR_SRC/check_transcripts_have_content.pl $LST_TRANS_TST_ORIG

  # Check audio files size
  perl $DIR_SRC/check_feature_obs.pl $LST_AUDIO_TRN_ORIG $MIN_OBS
  perl $DIR_SRC/check_feature_obs.pl $LST_AUDIO_TST_ORIG $MIN_OBS

fi

#============================================================
# Check dict
#============================================================
if [ $FLAG = 'dicts' ] || [ $FLAG = 'all_phases' ]; then
  perl $DIR_SRC/check_valid_dict_pronunciations.pl $DICT

  perl $DIR_SRC/check_words_in_dict.pl $LST_TRANS_TRN_ORIG $DICT
  perl $DIR_SRC/check_words_in_dict.pl $LST_TRANS_TST_ORIG $DICT

  perl $DIR_SRC/check_num_monophone_examples.pl $LST_TRANS_TRN_ORIG $DICT
fi

#============================================================
# Check transcription and dictionary format
#============================================================
if [ $FLAG = 'textformat' ] || [ $FLAG = 'all_phases' ]; then
  perl $DIR_SRC/check_for_things_that_break_htk.pl $LST_TRANS_TRN_ORIG $DICT
  perl $DIR_SRC/check_for_things_that_break_htk.pl $LST_TRANS_TST_ORIG $DICT
fi

echo "Checking done!"

