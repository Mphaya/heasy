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
# Check that software is present on the system
#
set -u

# Try and locate binaries
function check_for_binary() {
    local SOME_BINS=( "$@" )
    local exit_status=0

    for some_bin in "${SOME_BINS[@]}"; do
        type -p $some_bin &> /dev/null
        if [ $? -ne 0 ]; then
            exit_status=1
            echo "ERROR ($0): Cannot locate binary $some_bin" 1>&2
        fi
    done
    return $exit_status
}

# Try and locate binaries but only warn if not found
function check_for_binary_just_warn() {
    local custom_message=$1
    shift
    local SOME_BINS=( "$@" )

    for some_bin in "${SOME_BINS[@]}"; do
        type -p $some_bin &> /dev/null
        if [ $? -ne 0 ]; then
            echo "WARNING ($0): Cannot locate binary $some_bin - $custom_message" 1>&2
        fi
    done
}


# Test if scripts exist and are not empty
function check_for_script() {
    local script_dir=$1
    shift
    local SOME_SCRIPTS=( "$@" )
    local exit_status=0

    for some_script in "${SOME_SCRIPTS[@]}"; do
        full_script="$script_dir/$some_script"
        if [ ! -e $full_script ]; then
            exit_status=1
            echo "ERROR ($0): $full_script is missing! Should be in $script_dir" 1>&2
        fi
        if [ ! -s $full_script ]; then
            exit_status=1
            echo "ERROR ($0): $full_script is empty!" 1>&2
        fi
    done
    return $exit_status
}

EXPECTED_NUM_ARGS=1
if [ $# -lt $EXPECTED_NUM_ARGS ]; then
    echo "Usage: $0 <scripts_directory>"
    echo "scripts_directory - directory path containing perl/bash/python scripts"
    exit 1
fi

# List of needed software
HTK_BINS=( HCompV HLEd HHEd HERest HResults HVite )
SRI_BINS=( ngram-count )
JUICER_BINS=( juicer gramgen lexgen cdgen )
CUSTOM_BINS=( htksortdict )
PERL_SCRIPTS=( create_monophone_list.pl create_quests_file.pl create_mlf_from_text_files.pl check_every_audio_has_text_and_vv.pl check_num_monophone_examples.pl check_transcripts_have_content.pl check_valid_dict_pronunciations.pl check_words_in_dict.pl create_wordlist.pl build_sp_hmm.pl clone_tie_tri_hed.pl create_proto_from_pcf.pl context_cluster_hed.pl )
BASH_SCRIPTS=( create_init_models.sh )
PYTHON_SCRIPTS=()

# DIR_SRC should be passed as argument
DIR_SRC=`readlink -n -e $1`

# Will exit on this value if no errors occurred
RET_VAL=0

# Check that HTK binaries are present
echo "INFO ($0): Checking for HTK binaries"
check_for_binary "${HTK_BINS[@]}"
RET_VAL=$(($RET_VAL + $?))

# Check that Custom binaries are present
echo "INFO ($0): Checking for Custom binaries"
check_for_binary "${CUSTOM_BINS[@]}"
RET_VAL=$(($RET_VAL + $?))

# Check that Perl scripts are present
echo "INFO ($0): Checking for Perl scripts"
check_for_script $DIR_SRC "${PERL_SCRIPTS[@]}"
RET_VAL=$(($RET_VAL + $?))

# Check that Bash scripts are present
echo "INFO ($0): Checking for Bash scripts"
check_for_script $DIR_SRC "${BASH_SCRIPTS[@]}"
RET_VAL=$(($RET_VAL + $?))

# Check that SRI binaries are present
check_for_binary_just_warn "To install it see http://www.speech.sri.com/projects/srilm." "${SRI_BINS[@]}"

# Check that Juicer binaries are present
check_for_binary_just_warn "To install it see http://juicer.amiproject.org/juicer/. Also make sure you did 'export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/custom_path_to_own_software/lib'" "${JUICER_BINS[@]}"

# 0 on success else error occurred
exit $RET_VAL

