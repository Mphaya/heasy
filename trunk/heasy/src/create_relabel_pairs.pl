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

use warnings;
use strict;

use open IO => ':encoding(utf8)';

if((@ARGV + 0) != 2) {
  print "Usage: ./create_relabel_pairs <in:file_isyms> <out:file_isyms_new>\n\n";
  print "	<file_isyms> 	- isyms\n";
  print "	<file_isyms_new>- new isyms\n";
  exit 1;
}

my ($file_isyms, $file_out) = @ARGV;

open OUT, ">$file_out" or die "Can't open '$file_out' for writing!\n";

my %phns;
my $cnt = 0;

open FILE, "$file_isyms";
while(<FILE>) {
  chomp;
  my @tokens = split(/\s+/,$_);
  if (/#/) {
    $phns{$tokens[1]} = 0;
    print "$tokens[1]\t0\n";
  } else {
    $phns{$tokens[1]} = $cnt;
    print "$tokens[1]\t$cnt\n";
    print OUT "$tokens[0]\t$cnt\n";
    $cnt += 1;
  } 
}
close(FILE);
close(OUT);
