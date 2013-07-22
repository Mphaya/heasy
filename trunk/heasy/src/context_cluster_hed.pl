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

# Author: Neil Kleynhans
#
# Create HHEd script to cluster contexts
#

use strict;
use warnings;

use open IO => ":encoding(utf8)";
use open ':std';

if(scalar(@ARGV) != 4) {
    print "Usage: $0 <in:command> <in:threshold> <in:monophone_list> <out:hed_script>\n";
    exit 1;
}

my ($command, $threshold, $mono_file, $hed_file) = @ARGV;

open FIN, $mono_file or die "ERROR ($0): Cannot open file $mono_file\n";
open FOUT, ">>$hed_file" or die "ERROR ($0): Cannot open file $hed_file\n";

for (my $state_no = 2; $state_no < 5; $state_no++) {
    while(<FIN>) {
        chomp;
        next if (/^$/);
        print FOUT "$command $threshold \"ST_$_"."_$state_no"."_\" {(\"$_\",\"*-$_\+*\",\"$_\+*\",\"*-$_\").state[$state_no]}\n";
    }
    seek(FIN, 0, 0);
}

close(FIN);
close(FOUT);

