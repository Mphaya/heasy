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
# Uses sri's lm toolkit to train an ngram language model
set -eu

EXPECTED_NUM_ARGS=2
E_BAD_ARGS=65

if [ $# -ne $EXPECTED_NUM_ARGS ]; then
  echo "Usage: bash srilm_ngram_lm.sh <list trn> <ngram order>"
  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "list trn    " "- List of text files to use for training an lm"

  printf "\t%-4s $bold_begin%-12s$bold_end\t%s\n" "" "ngram order " "- if ngram order=3, a trigram language model will be trained."
  exit 1
fi

LOCAL_TRN_LIST=$1
LOCAL_NGRAM_ORDER=$2
LOCAL_VOCAB=""

# Make sure srilm is installed
type -P ngram-count &>/dev/null || { echo "ERROR: ngram-count not in PATH (did you install it? If not, see http://www.speech.sri.com/projects/srilm)" >&2; }

if [ ! -s $VOCABULARY ]; then
  $LOCAL_VOCAB="-write-vocab $VOCABULARY"
fi

# Create a temporary text file containing text from all files in LOCAL_TRN_LIST
if [ -s $DIR_SCRATCH/lm_text ]; then
  rm $DIR_SCRATCH/lm_text
fi

for i in $(cat $LOCAL_TRN_LIST)
do
  cat $i >> $DIR_SCRATCH/lm_text
done

ngram-count -order $LOCAL_NGRAM_ORDER $LOCAL_VOCAB -lm $GRAMMAR -text $DIR_SCRATCH/lm_text
rm $DIR_SCRATCH/lm_text

