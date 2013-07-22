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

# Author: Neil Kleynhans
#
# Perform MLLR estimation !!EXPERIMENTAL!!
#

# Commented out since -e  prevents messages from being printed
#set -eu

# Make sure file exist and not empty
function check_file {
    local file_name=$1

    [[ "$file_name" == "DEFAULT" ]] && return 0

    if [ ! -f $file_name ]; then
        echo "ERROR ($0): $file_name is not a valid file!" 1>&2
        exit 1
    elif [ ! -s $file_name ]; then
        echo "ERROR ($0): $file_name is empty!" 1>&2
        exit 1
    fi
}

# Make sure directory exists
function check_dir {
    local dir_name=$1

    [[ "$dir_name" == "DEFAULT" ]] && return 0

    if [ ! -d $dir_name ]; then
        echo "ERROR ($0): $dir_name is not a valid directory!" 1>&2
        exit 1
    fi
}

# Check is parameter is a valid option
function check_valid_option {
    local option=$1
    shift
    for n in "$@"; do
        [[ $n == $option ]] && return 0
    done

    echo "ERROR ($0): Options for -t are: MEAN or COV or MEAN_COV or CMLLR" 1>&2
    exit 1
}

MINIMUM_NUM_ARGS=5
if [ $# -lt $MINIMUM_NUM_ARGS ]; then
    echo "Usage: $0 -s DIR_SRC -e DIR_EXP -t MLLR_TYPE -c CONFIG1 -c CONFIG2 -a AUDIO_ADAPT_LIST -i ADAPT_MLF -m MASK -r REG_TREE"
    echo -e "\tDIR_SRC = directory containing heasy scripts"
    echo -e "\tDIR_EXP = directory containing experiment. We assume that DIR_EXP/models exists, if not, the script will not run."
    echo -e "\tMLLR_TYPE = MEAN or COV or MEAN_COV or CMLLR"
    echo -e "\tCONFIG_FILE_1 = 'DEFAULT' or configuration file containing MLLR settings."
    echo -e "\tCONFIG_FILE_2 (optional) = 'DEFAULT' or configuration file. Used when -t 'MEAN_COV' option specified."
    echo -e "\tAUDIO_ADAPT_LIST = list containing full paths to feature files."
    echo -e "\tREG_TREE_FILE = 'DEFAULT' or full path to custom regression class tree file."
    echo -e "\tADAPT_TRIPHONES_MLF = mlf file containing triphone expansion of sentences."
    echo -e "\tHTK_MASK = 'DEFAULT' (*.%%%) or custom file mask pattern."
    exit 1
fi

# Initialize variables
LOCAL_DIR_SRC=""
LOCAL_DIR_EXP=""
MLLR_TYPE=""
CONFIG1=""
CONFIG2=""
ADAPT_LIST=""
ADAPT_MLF=""
MASK=""
REG_TREE=""
HMM_DEF=""

# Parse the command line arguments
while getopts ":s:e:t:c:a:r:h:i:m:" opt; do
    case $opt in
    s)
        check_dir $OPTARG
        LOCAL_DIR_SRC=`readlink -n -e $OPTARG`
    ;;
    e)
        check_dir $OPTARG
        LOCAL_DIR_EXP=$OPTARG
        # These directories must exist
        check_dir $LOCAL_DIR_EXP/models
        check_dir $LOCAL_DIR_EXP/config
        check_dir $LOCAL_DIR_EXP/log
    ;;
    t)
        OPTIONS=( MEAN COV MEAN_COV CMLLR )
        check_valid_option $OPTARG "${OPTIONS[@]}"
        MLLR_TYPE=$OPTARG
    ;;
    c)
        if [ -z $CONFIG1 ]; then
            check_file $OPTARG
            CONFIG1=$OPTARG
        else
            check_file $OPTARG
            CONFIG2=$OPTARG
        fi
    ;;
    a)
        check_file $OPTARG
        ADAPT_LIST=`readlink -n -e $OPTARG`
    ;;
    i)
        check_file $OPTARG
        ADAPT_MLF=`readlink -n -e $OPTARG`
    ;;
    m)
        MASK=$OPTARG
        if [ $MASK = "DEFAULT" ]; then
            MASK="*.%%%"
        fi
    ;;
    r)
        check_file $OPTARG
        REG_TREE=$OPTARG
    ;;
    \?)
        echo "ERROR ($0): Invalid option -$OPTARG" 1>&2
        exit 1
    ;;
    esac
done

#####
# Perform some sanity checks
if [ $MLLR_TYPE = "MEAN_COV" ] && [ -z $CONFIG2 ]; then
    echo "ERROR ($0): -t is set to 'MEAN_COV' which requires a second config file - use -c twice" 1>&2
    exit 1
fi
#####

#####
echo "INFO ($0): Looking for last valid model in DIR_EXP=$LOCAL_DIR_EXP"
# Save DIR_EXP if it exists
SAVE_DIR_EXP=""
if [ ! -z $DIR_EXP ]; then
    SAVE_DIR_EXP=$DIR_EXP
fi

# Determine last valid model from experiment directory
# requires DIR_EXP variable to be set
export DIR_EXP=$LOCAL_DIR_EXP
source $LOCAL_DIR_SRC/inc_hmm_cnt.sh auto_update

# At this point DIR_HMM_PREV, DIR_HMM_CURR and DIR_HMM_NEXT should be set
if [[ -z $DIR_HMM_PREV ]] && [ $DIR_HMM_PREV -eq -1 ]; then
    echo "ERROR ($0): Cannot find valid 'hmmDefs.mmf' and 'macros' files in DIR_EXP=$LOCAL_DIR_EXP" 1>&2;
    exit 1
fi
echo "INFO ($0): Valid model set to $DIR_HMM_CURR"

# Restore DIR_EXP is SAVE_DIR_EXP if not empty
if [ ! -z $SAVE_DIR_EXP ]; then
    export DIR_EXP=$SAVE_DIR_EXP
fi
#####

#####
LOCAL_STATS="$LOCAL_DIR_EXP/config/stats"
check_file $LOCAL_STATS
echo "INFO ($0): Found training stats file $LOCAL_STATS"

# Find tiedlist in DIR_EXP/lists
LOCAL_TIED_LIST=`find $LOCAL_DIR_EXP/lists/ -type f -iname "tiedlist.lst" | tr -d '\n'`
check_file $LOCAL_TIED_LIST
echo "INFO ($0): Found tied training list $LOCAL_TIED_LIST"
#####

#####
# Setup REG_TREE if default
if [ $REG_TREE = 'DEFAULT' ]; then
    echo "INFO ($0): REG_TREE set to 'DEFAULT' will try and find regression class tree"
    # Look for file regtree*.tree
    possible_regtree=`find $LOCAL_DIR_EXP/models -type f -iname "regtree*.tree" | tr -d '\n'`

    if [ -z $possible_regtree ]; then
        # No regtree found will create default one
        echo "INFO ($0): Could not find regtree*.tree file in model directory: $LOCAL_DIR_EXP/models - creating regression class tree"

        # regtree.hed requires $STATS to be set
        export STATS=$LOCAL_DIR_EXP/config/stats
        check_file $STATS
        # Place regtree.hed in DIR_EXP/config
        REG_TREE_HED=$LOCAL_DIR_EXP/config/regtree.hed

        # Create default regtree.hed
        bash $LOCAL_DIR_SRC/create_configs.sh regtree_hed $REG_TREE_HED

        # Create regression class tree
        HHEd -A -D -V -T 1 -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -w /dev/null -M $DIR_HMM_CURR $REG_TREE_HED $LOCAL_TIED_LIST > $LOCAL_DIR_EXP/log/regtree.log 2> $LOCAL_DIR_EXP/log/regtree.err

        # Find regtree*.tree
        REG_TREE=`find $LOCAL_DIR_EXP/models -type f -iname "regtree*.tree"`
    else
        # We found a regtree*.tree use it
        REG_TREE=$possible_regtree
    fi

    # Make sure regtree file is okay
    check_file $REG_TREE
    echo "INFO ($0): REG_TREE set to $REG_TREE"
fi
#####

#####
# Set CLASSES directory
CLASSES=`dirname $REG_TREE | tr -d '\n'`

# Needed by create_configs.sh if 'mllr_mean', 'mllr_cov' and 'cmllr' are used
export REG_TREE_FILE=$REG_TREE

# Setup configration files
LOCAL_DIR_CFG="$LOCAL_DIR_EXP/config"
if [ $MLLR_TYPE = "MEAN" ]; then

    MEAN_CFG=$CONFIG1
    if [ $CONFIG1 = "DEFAULT" ]; then
        MEAN_CFG="$LOCAL_DIR_CFG/mllr_mean.cfg"
        bash $LOCAL_DIR_SRC/create_configs.sh 'mllr_mean' $MEAN_CFG
    fi
    echo "INFO ($0): Setting config file to $MEAN_CFG"

elif [ $MLLR_TYPE = "COV" ]; then

    COV_CFG=$CONFIG1
    if [ $CONFIG1 = "DEFAULT" ]; then
        COV_CFG="$LOCAL_DIR_CFG/mllr_cov.cfg"
        bash $LOCAL_DIR_SRC/create_configs.sh 'mllr_cov' $COV_CFG
    fi
    echo "INFO ($0): Setting config file to $COV_CFG"

elif [ $MLLR_TYPE = "MEAN_COV" ]; then

    MEAN_CFG=$CONFIG1
    if [ $CONFIG1 = "DEFAULT" ]; then
        MEAN_CFG="$LOCAL_DIR_CFG/mllr_mean.cfg"
        bash $LOCAL_DIR_SRC/create_configs.sh 'mllr_mean' $MEAN_CFG
    fi
    echo "INFO ($0): Setting first config file to $MEAN_CFG"

    COV_CFG=$CONFIG2
    if [ $CONFIG2 = "DEFAULT" ]; then
        COV_CFG="$LOCAL_DIR_CFG/mllr_cov.cfg"
        bash $LOCAL_DIR_SRC/create_configs.sh 'mllr_cov' $COV_CFG
    fi
    echo "INFO ($0): Setting second config file to $COV_CFG"

elif [ $MLLR_TYPE = "CMLLR" ]; then

    CMLLR_CFG=$CONFIG1
    if [ $CONFIG1 = "DEFAULT" ]; then
        CMLLR_CFG="$LOCAL_DIR_CFG/cmllr.cfg"
        bash $LOCAL_DIR_SRC/create_configs.sh 'cmllr' $CMLLR_CFG
    fi
    echo "INFO ($0): Setting config file to $CMLLR_CFG"

fi
#####

#####
# Convert HTK Mask to Bash regex
# E.G. '*.%%%' becomes '.*\.(.)(.)(.)'
echo "INFO ($0): Converting HTK mask to Bash regex"
regex=`echo $MASK | sed "s:'::g;s:\"::g"`
regex=`echo $regex | sed 's:\.:\\\.:g;s:\*:.*:g;s:%:\(\.\):g'`
count=$regex
count="${count//[^(]/}" # This is bit hacky - only counting '(' would rather count '(.)'
count=`echo ${#count}`
echo "INFO ($0): HTK mask '$MASK' transformed to Bash regex '$regex'"

# Get first audio file from script file
STR=`head -n 1 $ADAPT_LIST`
MASK_CHARS=""
[[ $STR =~ $regex ]]
for (( n=1; n <= $count; n++ )); do
   MASK_CHARS="$MASK_CHARS${BASH_REMATCH[$n]}"
done
if [ -z $MASK_CHARS ]; then
    echo "ERROR ($0): Cannot convert HTK MASK ($MASK) to bash regex!" 1>&2
    exit 1
fi
#####

#####
# Check for Parent transform like SEMITIED
echo "INFO ($0): Looking for parent transform in $DIR_HMM_CURR"
PARENT_TRANS_FULL=`cat $DIR_HMM_CURR/hmmDefs.mmf | grep "<PARENTXFORM>" | sed 's:"::g' | tr -d '\n'`
PARENT_XFORMS=""
USE_INPUT_XFORM=""

if [ -n "$PARENT_TRANS_FULL" ]; then
    echo "INFO ($0): Found parent transform $PARENT_TRANS_FULL"
    PARENT_TRANS_FILE=`echo -n $PARENT_TRANS_FULL | awk {'print $NF'}`
    PARENT_TRANS_DIR=`dirname $PARENT_TRANS_FILE`
    PARENT_TRANS_NAME=`basename $PARENT_TRANS_FILE`
    PARENT_XFORMS="-a -E $PARENT_TRANS_DIR -J $PARENT_TRANS_DIR"

    echo "INFO ($0): Renaming parent transform from '$PARENT_TRANS_FILE' to '$MASK_CHARS'"
    # Have to change the parent transform's file name
    cp $PARENT_TRANS_FILE $PARENT_TRANS_DIR/$MASK_CHARS

    # Delete '~a' line in transfrom file
    sed -i '/^~a/d' $PARENT_TRANS_DIR/$MASK_CHARS

    # Change parent transform name to mask in hmm defs file
    sed -i "s:"$PARENT_TRANS_NAME":"$MASK_CHARS":g" $DIR_HMM_CURR/hmmDefs.mmf

    # Delete duplicate parentxform tag
    sed -i '/^<PARENTXFORM>/d' $DIR_HMM_CURR/macros

    # Change parent transform name to mask in transform file
    sed -i "s:"$PARENT_TRANS_NAME":"$MASK_CHARS":g" $PARENT_TRANS_DIR/$MASK_CHARS
fi
#####

#####
# Find defunct mixtures and fix
echo "INFO ($0): Looking for defunct mixtures in model file $DIR_HMM_CURR"
echo "INFO ($0): To prevent defunct mixtures set mixture weight (-w 1.1) in herest.sh"
perl $LOCAL_DIR_SRC/find_and_fix_states_with_defunct_mixtures.pl $DIR_HMM_CURR/hmmDefs.mmf

if [ -f $DIR_HMM_CURR/hmmDefs.mmf.tmp ]; then
   cp $DIR_HMM_CURR/hmmDefs.mmf $DIR_HMM_CURR/hmmDefs.mmf.defunct
   mv $DIR_HMM_CURR/hmmDefs.mmf.tmp $DIR_HMM_CURR/hmmDefs.mmf
fi
#####

#####
# Training routines
if [ $MLLR_TYPE = "MEAN" ]; then

    echo "INFO ($0): Training MLLR MEAN transform"
#HERest -A -D -T 1 -a -C $MEAN_CFG -S $SCP -I $MLF -E $CLASSES -K $XFORMS mllr1 -J $CLASSES -H $MACROS -u a -H $HMMDEF -h '*.%%%' $TIEDLIST > $OUTPUT_DIR/logs/mean.log
    HERest -A -D -T 1 -C $MEAN_CFG -S $ADAPT_LIST -I $ADAPT_MLF $PARENT_XFORMS -J $CLASSES -K $DIR_HMM_CURR mllr_mean -H $DIR_HMM_CURR/macros -u a -H $DIR_HMM_CURR/hmmDefs.mmf -h $MASK $LOCAL_TIED_LIST > $LOCAL_DIR_EXP/log/mllr_mean.log 2> $LOCAL_DIR_EXP/log/mllr_mean.err

    check_file $DIR_HMM_CURR/$MASK_CHARS.mllr_mean
    echo "INFO ($0): $DIR_HMM_CURR/$MASK_CHARS.mllr_mean transform created"

elif [ $MLLR_TYPE = "COV" ]; then

    echo "INFO ($0): Training MLLR COV transform"

    HERest -A -D -T 1 -C $COV_CFG -S $ADAPT_LIST -I $ADAPT_MLF $PARENT_XFORMS -J $CLASSES -K $DIR_HMM_CURR mllr_cov -H $DIR_HMM_CURR/macros -u a -H $DIR_HMM_CURR/hmmDefs.mmf -h $MASK $LOCAL_TIED_LIST > $LOCAL_DIR_EXP/log/mllr_cov.log 2> $LOCAL_DIR_EXP/log/mllr_cov.err

    check_file $DIR_HMM_CURR/$MASK_CHARS.mllr_cov
    echo "INFO ($0): $DIR_HMM_CURR/$MASK_CHARS.mllr_cov transform created"

elif [ $MLLR_TYPE = "MEAN_COV" ]; then

    echo "INFO ($0): Training MLLR MEAN transform"

    HERest -A -D -T 1 -C $MEAN_CFG -S $ADAPT_LIST -I $ADAPT_MLF $PARENT_XFORMS -J $CLASSES -K $DIR_HMM_CURR mllr_mean -H $DIR_HMM_CURR/macros -u a -H $DIR_HMM_CURR/hmmDefs.mmf -h $MASK $LOCAL_TIED_LIST > $LOCAL_DIR_EXP/log/mllr_mean.log 2> $LOCAL_DIR_EXP/log/mllr_mean.err

    check_file $DIR_HMM_CURR/$MASK_CHARS.mllr_mean
    echo "INFO ($0): $DIR_HMM_CURR/$MASK_CHARS.mllr_mean transform created"

    echo "INFO ($0): Training MLLR COV transform"

    # Update input transform to include $MASK.mllr_mean
    if [ -z "$PARENT_XFORMS" ] ;then
        PARENT_XFORMS="-a -J $DIR_HMM_CURR mllr_mean -J $CLASSES"
    else
        PARENT_XFORMS="$PARENT_XFORMS -J $DIR_HMM_CURR mllr_mean -J $CLASSES"
    fi

    HERest -A -D -T 1 -C $COV_CFG -S $ADAPT_LIST -I $ADAPT_MLF $PARENT_XFORMS -K $DIR_HMM_CURR mllr_cov -H $DIR_HMM_CURR/macros -u a -H $DIR_HMM_CURR/hmmDefs.mmf -h $MASK $LOCAL_TIED_LIST > $LOCAL_DIR_EXP/log/mllr_cov.log 2> $LOCAL_DIR_EXP/log/mllr_cov.err

    check_file $DIR_HMM_CURR/$MASK_CHARS.mllr_cov
    echo "INFO ($0): $DIR_HMM_CURR/$MASK_CHARS.mllr_cov transform created"

elif [ $MLLR_TYPE = "CMLLR" ]; then

    echo "INFO ($0): Training MLLR CMLLR transform"
    HERest -A -D -T 1 -C $CMLLR_CFG -S $ADAPT_LIST -I $ADAPT_MLF $PARENT_XFORMS -J $CLASSES -K $DIR_HMM_CURR mllr_cmllr -H $DIR_HMM_CURR/macros -u a -H $DIR_HMM_CURR/hmmDefs.mmf -h $MASK $LOCAL_TIED_LIST > $LOCAL_DIR_EXP/log/cmllr.log 2> $LOCAL_DIR_EXP/log/cmllr.err

    check_file $DIR_HMM_CURR/$MASK_CHARS.mllr_cmllr
    echo "INFO ($0): $DIR_HMM_CURR/$MASK_CHARS.mllr_cmllr transform created"

    # Use $MASK.mllr_cmllr as input transform
    if [ -z "$PARENT_XFORMS" ]; then
        PARENT_XFORMS="-a"
    fi

    # Retrain HMM with $MASK.mllr_cmllr as input transform
    # Parallize this training
    HERest -A -D -T 1 -C $CMLLR_CFG -S $ADAPT_LIST -I $ADAPT_MLF $PARENT_XFORMS -J $DIR_HMM_CURR mllr_cmllr -J $CLASSES -H $DIR_HMM_CURR/macros -H $DIR_HMM_CURR/hmmDefs.mmf -M $DIR_HMM_NEXT -h $MASK $LOCAL_TIED_LIST >> $LOCAL_DIR_EXP/log/cmllr.log 2>> $LOCAL_DIR_EXP/log/cmllr.err

fi
#####

