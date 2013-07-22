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

echo "Copying ../heasy/experiment_template to experiment_template/"
cp -r ../heasy/experiment_template .

echo "Fixing variables in Vars.sh"

DIR_ROOT=`pwd`
DIR_SRC=`readlink -f ../heasy/src | tr -d '\n'`

sed -i 's:export DIR_ROOT=~/work/asr/beta:export DIR_ROOT='$DIR_ROOT':g' ./experiment_template/Vars.sh
sed -i 's:export DIR_EXP=$DIR_ROOT/test_data/experiment4:export DIR_EXP=$DIR_ROOT/experiment:g'  ./experiment_template/Vars.sh
sed -i 's:export DIR_SRC=$DIR_ROOT/heasy/src:export DIR_SRC='$DIR_SRC':g' ./experiment_template/Vars.sh
sed -i 's:export DIR_CFG=$DIR_ROOT/heasy/config:export DIR_CFG=$DIR_ROOT/config:g' ./experiment_template/Vars.sh

sed -i 's:export LST_AUDIO_TRN_ORIG=$DIR_ROOT/heasy/experiment_template/audio_trn.lst:export LST_AUDIO_TRN_ORIG=$DIR_ROOT/lists/audio_trn.lst:g' ./experiment_template/Vars.sh
sed -i 's:export LST_AUDIO_TST_ORIG=$DIR_ROOT/heasy/experiment_template/audio_tst.lst:export LST_AUDIO_TST_ORIG=$DIR_ROOT/lists/audio_tst.lst:g' ./experiment_template/Vars.sh

sed -i 's:export LST_TRANS_TRN_ORIG=$DIR_ROOT/heasy/experiment_template/trans_trn.lst:export LST_TRANS_TRN_ORIG=$DIR_ROOT/lists/trans_trn.lst:g' ./experiment_template/Vars.sh
sed -i 's:export LST_TRANS_TST_ORIG=$DIR_ROOT/heasy/experiment_template/trans_tst.lst:export LST_TRANS_TST_ORIG=$DIR_ROOT/lists/trans_tst.lst:g' ./experiment_template/Vars.sh

sed -i 's:export DICT=$DIR_ROOT/dicts/cmu.sorted.dict:export DICT=$DIR_ROOT/dicts/english.graph.dict:g' ./experiment_template/Vars.sh

echo "Creating directories - config/ experiment/ lists/ dicts/"
mkdir -p config experiment lists dicts

