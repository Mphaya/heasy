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

#==============================================================================
# Create semit and regtree configs (required)
#==============================================================================
# WARNING: There shouldn't be any defunct mixtures! See utility scripts for a 
#          perl script which can replace defunct mixtures with the last split
#          model.

# Create the configuration file
# TODO(Charl): Currently, we assume that HADAPT_BASECLASS and HADAPT_SEMITIEDMACRO
#              will be set by the user.

if [ -z $HADAPT_BASECLASS ] || [ -z $HADAPT_SEMITIEDMACRO ]; then
  echo "WARNING: HADAPT_BASECLASS and/or HADAPT_SEMITIEDMACRO not set!"
  echo "WARNING: Setting HADAPT_BASECLASS and HADAPT_SEMITIEDMACRO automatically!"
  source $DIR_SRC/inc_hmm_cnt.sh auto_update
  export HADAPT_BASECLASS=$DIR_HMM_CURR/regtree_2.base
  export HADAPT_SEMITIEDMACRO=$DIR_HMM_CURR/SEMITIED
fi

if [ ! -s $HED_REGTREE ]; then
  echo "INIT: Creating $HED_REGTREE"
  bash $DIR_SRC/create_configs.sh regtree_hed $HED_REGTREE
else
  echo "INIT: $HED_REGTREE already exists. Using as is."
fi

if [ ! -s $CFG_SEMITIED ]; then
  echo "INIT: Creating $CFG_SEMITIED"
  bash $DIR_SRC/create_configs.sh semit $CFG_SEMITIED
else
  echo "INIT: $CFG_SEMITIED already exists. Using as is."
fi

#==============================================================================
# Estimate semitied transform
#==============================================================================
source $DIR_SRC/inc_hmm_cnt.sh auto_update
HHEd -A -D -V -T 1 -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -w /dev/null -M $DIR_HMM_CURR $HED_REGTREE $LIST_TIED 

#TODO: parallelize?

if [ $NUM_HEREST_PROCS -eq 1 ]; then
  HERest -A -D -T 1 -V -C $CFG_SEMITIED -S $LIST_AUDIO_TRN -I $MLF_TRIPHNS_TRN -u stw -t $HEREST_PRUNE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -K $DIR_HMM_CURR -M $DIR_HMM_NEXT -s $STATS $LIST_TIED
  source $DIR_SRC/inc_hmm_cnt.sh auto_update
else
  cd $DIR_SCRATCH
  mkdir -p herest_lists
  rm -f herest_lists/*
  cd herest_lists

  #Usage: ./split.pl <list.txt> <num splits> <dir_out>
  perl $DIR_SRC/split.pl $LIST_AUDIO_TRN $NUM_HEREST_PROCS $DIR_SCRATCH/herest_lists
  cnt=1
  for list in `ls *`
  do
    HERest -A -D -T 1 -V -p $cnt -C $CFG_SEMITIED -S $list -I $MLF_TRIPHNS_TRN -u stw -t $HEREST_PRUNE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -K $DIR_HMM_CURR -M $DIR_HMM_NEXT -s $STATS $LIST_TIED > log.$cnt &
    cnt=$(($cnt + 1))
  done
  wait

  acc_files=""
  for acc in `ls $DIR_HMM_NEXT/*.acc`
  do
    acc_files="$acc_files $acc"
  done
  cat log.*
  HERest -A -D -T 1 -V -p 0 -C $CFG_SEMITIED -I $MLF_TRIPHNS_TRN -u stw -t $HEREST_PRUNE -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -K $DIR_HMM_CURR -M $DIR_HMM_NEXT -s $STATS $LIST_TIED $acc_files
  rm -f $DIR_HMM_NEXT/*.acc
  source $DIR_SRC/inc_hmm_cnt.sh auto_update
fi

# TODO: HERest expects -K and -J to be before -M. Decision for now: do HERest explicitely instead of complicating herest.sh
bash $DIR_SRC/herest.sh $LIST_TIED $MLF_TRIPHNS_TRN 2
