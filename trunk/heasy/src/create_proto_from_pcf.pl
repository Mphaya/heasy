#!/usr/bin/perl
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

# Author:  Neil Kleynhans
#
# Convert PCF to proto model
#

use strict;
use warnings;

use open IO => ":encoding(utf8)";
use open ':std';

# Load variables from a pcf config file and return a hash 
sub parse_pcf($) {
    my ($pcf_file) = @_;

    # Initialize parameters
    my %config = (
        hsKind => "",
        covKind => "",
        nStates => "",
        nStreams => "",
        sWidths => "",
        mixes => "",
        parmKind => "",
        vecSize => "",
        outDir => "",
        hmmList => ""
    );

    my @proper_keys = keys %config;
    my $valid_count = 4;
    open FIN,$pcf_file or die "ERROR ($0): Cannot open $pcf_file - $?";
    while(<FIN>) {
        chomp;
        next if(/^$/);

        # These tags should appear in the PCF configuration file
        if (/^</) {
            if(/<BEGINproto_config_file>/) { $valid_count--; }
            if(/<BEGINsys_setup>/) { $valid_count--; }
            if(/<ENDsys_setup>/) { $valid_count--; }
            if(/<ENDproto_config_file>/) { $valid_count--; }
            next;
        }
        # Read in parm:value pair
        if (/(.+):(.+)/) {
            my $parm = $1;
            my $value = $2;
            $value =~ s/\s+//g;
            $config{$parm} = $value;
        }
    }
    close(FIN);

    # Check if we have a valid PCF configuration file
    if ($valid_count != 0) {
        die "ERROR ($0): Not a valid PCF configuration file. Please check $pcf_file\n";
    }

    # Check if parms were set
    my $error_flag = 0;
    foreach my $key (@proper_keys) {
        if (exists($config{$key})) {
            if ($config{$key} eq "") {
                $error_flag++;
                print STDERR "ERROR ($0): Parameter $key not set in PCF configuration file $pcf_file\n";
            }
        } else {
            $error_flag++;
            print STDERR "ERROR ($0): Expected parameter $key to be set in the PCF configuration file $pcf_file\n";
        }
    }

    if ($error_flag != 0) {
        die "ERROR ($0): Parameters not set in PCF configuration file $pcf_file\n";
    }

    return %config;
}

# Make sure parameters are valid
sub check_parms(%) {
    my (%config) = @_;

    #Valid tags: hsKind covKind nStates nStreams sWidths mixes vecSize

    if(uc($config{"hsKind"}) !~ /P/) {
        die "ERROR ($0): Currently only hsKind = P supported\n";
    }

    if(uc($config{"covKind"}) !~ /D/) {
        die "ERROR ($0): Currently only covKind = D supported\n";
    }

    if($config{"nStates"} < 2) {
        die "ERROR ($0): nStates must be greater than 1\n";
    }

    if($config{"nStreams"} !~ /^\d+$/) {
        die "ERROR ($0): nStreams must be an integer\n";
    }
    if($config{"nStreams"} != 1) {
        die "ERROR ($0): Currently only nStreams = 1 supported\n";
    }

    if($config{"sWidths"} !~ /^\d+$/) {
        die "ERROR ($0): sWidths must be an integer\n";
    }
    if($config{"sWidths"} < 0) {
        die "ERROR ($0): sWidths must be greater than 0\n";
    }

    if($config{"mixes"} !~ /(\d+)/) {
        die "ERROR ($0): mixes must be an integer\n";
    }
    if($config{"mixes"} < 0) {
        die "ERROR ($0): mixes must be greater than 0\n";
    }

    if($config{"vecSize"} !~ /^\d+$/) {
        die "ERROR ($0): vecSize must be an integer\n";
    }
    if($config{"vecSize"} < 0) {
        die "ERROR ($0): vecSize must be greater than 0\n";
    }
}

# Given the loaded PCF configuration build the model
sub build_model(%) {
    my (%config) = @_;

    # Read in model names
    my $hmmList = $config{"hmmList"};
    open FLIST, $hmmList or die "ERROR ($0): Cannot open $hmmList\n";
    my @model_names = ();
    while(<FLIST>) {
        chomp;
        push @model_names, $_;
    }
    close(FLIST);

    my $out_file = $config{"outDir"};
    $out_file = "$out_file/proto";
    open FOUT, ">$out_file" or die "ERROR ($0): Cannot open $out_file\n";

    # Write Header
    my $vec_size = $config{"vecSize"};
    my $parm_kind = $config{"parmKind"};
    my $n_streams = $config{"nStreams"};
    my $s_widths = $config{"sWidths"};
    print FOUT "~o <VecSize> $vec_size <$parm_kind> <StreamInfo> $n_streams $s_widths\n";

    # Create a HMM for each model name
    foreach my $hmm_name (@model_names) {
        # Write model name
        print FOUT "~h \"$hmm_name\"\n";
        # Begin HMM
        print FOUT "<BeginHMM>\n";

        # Total number of states
        my $n_states = $config{"nStates"};
        my $total_states = $n_states + 2;
        print FOUT "\t<NumStates> $total_states\n";

        # Cycle through states
        for(my $SN = 2; $SN < $total_states; $SN++) {
            # Which state
            print FOUT "\t<State> $SN\n";

            # Number of mixtures
            my $no_mixes = $config{"mixes"};
            print FOUT "\t<NumMixes> $no_mixes\n";
            my $mix_weight = sprintf("%.5f", 1.0 / $no_mixes);

            # Cycle through mixtures
            for(my $MN = 1; $MN <= $no_mixes; $MN++) {
                # which mixture
                print FOUT "\t\t<Mixture> $MN $mix_weight\n";
                
                # Write Mean
                print FOUT "\t\t\t<Mean> $s_widths\n";
                my @mean = (("0.0") x $s_widths);
                print FOUT "\t\t\t\t@mean\n";

                # Write Variance
                print FOUT "\t\t\t<Variance> $s_widths\n";
                my @var = (("1.0") x $s_widths);
                print FOUT "\t\t\t\t@var\n";
            }
        }

        # Write transition matrix
        print FOUT "\t<TransP> $total_states\n";
        # Start
        my @start_trans = ((0.0) x $total_states);
        $start_trans[1] = 1.0;
        print FOUT "\t";
        foreach my $val (@start_trans) {
            printf FOUT " %.4e", $val;
        }
        print FOUT "\n";

        # Middle
        my @mid_trans = ((0.0) x $total_states);
        $mid_trans[1] = 0.6;
        $mid_trans[2] = 0.4;

        for(my $ti = 2; $ti < $total_states; $ti++) {
            print FOUT "\t";
            foreach my $val (@mid_trans) {
                printf FOUT " %.4e", $val;
            }
            print FOUT "\n";

            my $end_val = pop @mid_trans;
            unshift @mid_trans, $end_val;
        }

        # End
        my @end_trans = ((0.0) x $total_states);
        print FOUT "\t";
        foreach my $val (@end_trans) {
            printf FOUT " %.4e", $val;
        }
        print FOUT "\n";

        # End HMM
        print FOUT "<EndHMM>\n";
    }

    close(FOUT);
}


if(scalar(@ARGV) != 1) {
    print "Usage: $0 pcf_config\n";
    print "\tpcf_config - contains the configuration describing the proto HMM\n";
    exit 1;
}

my ($pcf_file) = @ARGV;

my %config = parse_pcf($pcf_file);
check_parms(%config);
build_model(%config);

