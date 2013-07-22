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
# Build "sp" tee hmm using "sil" state 3
#

use strict;
use warnings;

use open IO => ":encoding(utf8)";
use open ':std';

if(scalar(@ARGV) != 2) {
    die "Usage: $0 <in:hmm_defs-no_sp> <out:hmm_defs-sp>\n";
}

my ($in_defs, $out_defs) = @ARGV;

open FIN, $in_defs or die "ERROR ($0): Cannot open $in_defs\n";
open FOUT, ">$out_defs" or die "ERROR ($0): Cannot open $out_defs\n";

my @buffer = ();
my $reached_sil = 0;

while(<FIN>) {
    print FOUT "$_";

    if(/^~h "sil"/) {
        $reached_sil = 1;
        next;
    }

    if($reached_sil > 0)  {
        if(/<STATE> 4/) {
            $reached_sil = 0;
            next;
        }
        elsif($reached_sil == 2) {
            push @buffer, $_;
        }
        elsif(/<STATE> 3/) {
            $reached_sil = 2;
            next;
        }
    }
}

print FOUT "~h \"sp\"\n";
print FOUT "<BEGINHMM>\n";
print FOUT "<NUMSTATES> 3\n";
print FOUT "<STATE> 2\n";
print FOUT "@buffer";
print FOUT "<TRANSP> 3\n";
print FOUT " 0.000000e+00 5.000000e-01 5.000000e-01\n";
print FOUT " 0.000000e+00 5.000000e-01 5.000000e-01\n";
print FOUT " 0.000000e+00 0.000000e+00 0.000000e+00\n";
print FOUT "<ENDHMM>\n";

close(FIN);
close(FOUT);

