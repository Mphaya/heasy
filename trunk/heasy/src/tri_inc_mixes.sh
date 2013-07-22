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

LOCAL_NUM_ITERATIONS=$NUM_MIXES

while [ $LOCAL_NUM_ITERATIONS -gt 1 ]; do # -gt 1, because we already have one mixture
  LOCAL_NUM_ITERATIONS=$(($LOCAL_NUM_ITERATIONS-1))
#==============================================================================
# Increment the mixtures
#==============================================================================
# Make sure the hmm dirs are up to date
  source $DIR_SRC/inc_hmm_cnt.sh auto_update
  HHEd -A -D -T 1 -V -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -M $DIR_HMM_NEXT $HED_MIX_INC $LIST_TIED

#==============================================================================
# Re-estimate twice
#==============================================================================
# ./herest.sh <model list> <trn mlf> <num re-estimations>
  bash $DIR_SRC/herest.sh $LIST_TIED $MLF_TRIPHNS_TRN 2
done

