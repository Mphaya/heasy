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
# Generate HHEd script to clone triphones and tie transition matrices
#

use strict;
use warnings;

use open IO => ":encoding(utf8)";
use open ':std';

if(scalar(@ARGV) != 3) {
    print "Usage: $0 <in:monophone_list> <in:triphone_list> <out:hed_script>\n";
    exit 1;
}

my ($mono_file, $tri_file, $hed_file) = @ARGV;

open FHED, ">$hed_file" or die "ERROR ($0): Cannot open $hed_file\n";
open FMONO, $mono_file or die "ERROR ($0): Cannot open $mono_file\n";

print FHED "CL $tri_file\n";
while(<FMONO>) {
    chomp;
    next if (/^$/);
    print FHED "TI T_$_ {(*-$_+*,$_+*,*-$_).transP}\n";
}

close(FMONO);
close(FHED);

