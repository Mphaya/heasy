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

# Create a phn loop grammar
bash $DIR_SRC/loop_grammar.sh $LIST_MONOPHNS

# Create a monophone dictionary (ph ph)
cat $LIST_MONOPHNS | sed '/sp/d' | awk '{print $1 "\t" $1}' > $DIR_SCRATCH/mono.dict.tmp
echo -e "$SENTSTART [] sil\n$SENTEND [] sil" >> $DIR_SCRATCH/mono.dict.tmp
cat $DIR_SCRATCH/mono.dict.tmp | sort -u > $DIR_EXP/dictionaries/mono.decode.dict
rm $DIR_SCRATCH/mono.dict.tmp

bash $DIR_SRC/decode.sh $LIST_TIED $GRAMMAR $DIR_EXP/dictionaries/mono.decode.dict

