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

echo "Warning: Decoding using Juicer is still being tested!"

perl $DIR_SRC/reduce_dict.pl $LIST_TRANS_TRN $DICT_SP > $DIR_EXP/dictionaries/reduced_dict.dict

echo "juicer -writeBinaryFiles -sentStartWord "$SENTSTART" -sentEndWord "$SENTEND" -mainBeam $MAINBEAM -tiedListFName $LIST_TIED -cdSepChars +- -inputFormat htk -lexFName $DIR_EXP/dictionaries/reduced_dict.dict -inputFName $LIST_AUDIO_TST -fsmFName $DIR_EXP/grammar/CLG.fst -inSymsFName $DIR_EXP/grammar/CLG.isyms -outSymsFName $DIR_EXP/grammar/CLG.osyms -htkModelsFName $DIR_EXP/models/hmm_33/hmmDefs.mmf"

juicer -writeBinaryFiles -sentStartWord "$SENTSTART" -sentEndWord "$SENTEND" -mainBeam $MAINBEAM -tiedListFName $LIST_TIED -cdSepChars +- -inputFormat htk -lexFName $DIR_EXP/dictionaries/reduced_dict.dict -inputFName $LIST_AUDIO_TST -fsmFName $DIR_EXP/grammar/CLG.fst -inSymsFName $DIR_EXP/grammar/CLG.isyms -outSymsFName $DIR_EXP/grammar/CLG.osyms -htkModelsFName $DIR_EXP/models/hmm_33/hmmDefs.mmf

#-outputFormat mlf -outputFName $DIR_EXP/results/juicer.results

# Different ways Juicer has been run

#echo "juicer -writeBinaryFiles -sentStartWord "$SENTSTART" -sentEndWord "$SENTEND" -mainBeam 100 -tiedListFName $LIST_TIED -cdSepChars +- -inputFormat htk -lexFName $DIR_EXP/dictionaries/reduced_dict.dict -inputFName $LIST_AUDIO_TST -fsmFName $DIR_EXP/grammar/CLG.fst -inSymsFName $DIR_EXP/grammar/CLG.isyms -outSymsFName $DIR_EXP/grammar/CLG.osyms -htkModelsFName $DIR_EXP/models/hmm_33/hmmDefs.mmf"
#echo "juicer -writeBinaryFiles -sentStartWord "$SENTSTART" -sentEndWord "$SENTEND" -mainBeam 200 -tiedListFName $LIST_TIED -cdSepChars +- -inputFormat htk -lexFName $DIR_EXP/dictionaries/reduced_dict.dict -inputFName $LIST_AUDIO_TST -fsmFName $DIR_EXP/grammar/CLG.fst -inSymsFName $DIR_EXP/grammar/CLG.isyms -outSymsFName $DIR_EXP/grammar/CLG.osyms -htkModelsFName $DIR_EXP/models/hmm_33/hmmDefs.mmf  -phoneStartBeam 200 -phoneEndBeam 200 -wordEmitBeam 400 -maxHyps 500"

#juicer -writeBinaryFiles -sentStartWord "<s>" -sentEndWord "</s>" -silMonophone "sil" -pauseMonophone "sp" -mainBeam 200 -tiedListFName /home/cvheerden/work/asr/beta/test_data/experiment4/lists/tiedlist.lst -cdSepChars -+ -inputFormat htk -lexFName /home/cvheerden/work/asr/beta/test_data/experiment4/dictionaries/reduced_dict.dict -inputFName /home/cvheerden/work/asr/beta/test_data/experiment4/lists/audio_tst.lst -fsmFName /home/cvheerden/work/asr/beta/test_data/experiment4/grammar/CLG.fst -inSymsFName /home/cvheerden/work/asr/beta/test_data/experiment4/grammar/CLG.isyms -outSymsFName /home/cvheerden/work/asr/beta/test_data/experiment4/grammar/CLG.osyms -htkModelsFName /home/cvheerden/work/asr/beta/test_data/experiment4/models/hmm_33/hmmDefs.mmf  -phoneStartBeam 10000 -phoneEndBeam 10000 -wordEmitBeam 10000 -maxHyps 1000 -outputFormat mlf -outputFName ../../test_data/experiment4/results/juicer.results
