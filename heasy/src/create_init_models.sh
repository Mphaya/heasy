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

#Author: Neil Kleynhans (ntkleynhans@csir.co.za)
# x
set -eu

#Check if monophones.lst exists
if [ ! -f $LIST_MONOPHNS ]; then
    echo "ERROR ($0): Cannot find monophone list file: " $LIST_MONOPHNS
    exit 1;
fi

if [ -f $DIR_HMM_CURR/hmmDefs.mmf ]; then
    rm $DIR_HMM_CURR/hmmDefs.mmf
fi

Skip="+1"

for monoph in $(cat $LIST_MONOPHNS | sort); do
    echo "Adding model:" $monoph

    cat $PROTO_SET | tail -n $Skip | sed 's/proto/'$monoph'/g' >> $DIR_HMM_CURR/hmmDefs.mmf

    if [ $Skip = "+1" ]; then
        # Create macros files
        cat $PROTO_SET | head -n 3 > $DIR_HMM_CURR/macros
        cat $VFLOORS >> $DIR_HMM_CURR/macros
        Skip="+4"
    fi
done

