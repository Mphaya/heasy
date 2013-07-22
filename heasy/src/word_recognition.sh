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
set -eu

# Create a word loop grammar (TODO: One would typically use a BI or TRIGRAM word model here)
bash $DIR_SRC/loop_grammar.sh $LIST_WORDS_TRN

bash $DIR_SRC/decode.sh $LIST_TIED $GRAMMAR $DICT_SP

# Using HVite to do bigram recognition could be done as follows

# Build a bigram word network
#HBuild -t $SENTSTART $SENTEND $LOCAL_LIST_TOKENS -n $GRAMMAR $DIR_EXP/grammar/loop_grammar.txt
#HBuild -s '<s>' '</s>' -n /home/cvheerden/work/asr/beta/test_data/experiment4/grammar/grammar.txt /home/cvheerden/work/asr/beta/test_data/experiment4/lists/words_trn.lst /home/cvheerden/work/asr/beta/test_data/experiment4/grammar/loop_grammar.txt

# Do recognition using the bigram network
#bash $DIR_SRC/decode.sh $LIST_TIED $DIR_EXP/grammar/loop_grammar.txt $DICT_SP

