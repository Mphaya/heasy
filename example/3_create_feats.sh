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

echo "Creating features using experiment_template/FEATURE_EXTRACTION.sh"

# Create a HTK-style scp file
mkdir -p data/mfccs
MFCC_PATH=`readlink -f data/mfccs | tr -d '\n'`
DATA_PATH=`readlink -f data/ASR.Lwazi.Eng.1.0/audio | tr -d '\n'`
find $DATA_PATH -type f -iname '*.wav' | sort > 1.lst

cat 1.lst | awk -F '/' -v x=$MFCC_PATH/ {'print x$NF'} | sed 's:\.wav:\.mfc:g' > 2.lst
paste 1.lst 2.lst > data/mfcc.scp

rm 1.lst 2.lst

cd experiment_template
./FEATURE_EXTRACTION.sh ../data/mfcc.scp
cd ..

