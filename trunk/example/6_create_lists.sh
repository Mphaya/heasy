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

echo "Creating train and test lists"

MFCC_PATH=`readlink -f data/mfccs | tr -d '\n'`
TEXT_PATH=`readlink -f data/texts | tr -d '\n'`

find $MFCC_PATH -type f | sort | grep -P '_0(1|2)(\d)_' > lists/audio_tst.lst
find $MFCC_PATH -type f | sort | grep -vP '_0(1|2)(\d)_' > lists/audio_trn.lst

find $TEXT_PATH -type f | sort | grep -P '_0(1|2)(\d)_' > lists/trans_tst.lst
find $TEXT_PATH -type f | sort | grep -vP '_0(1|2)(\d)_' > lists/trans_trn.lst

