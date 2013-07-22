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
use List::Util 'shuffle';
use open IO => ':encoding(utf8)';
use open ':std';

if (scalar(@ARGV) != 3) {
  print "Usage: ./split.pl <in:list.txt> <par:num splits> <out:dir_out>\n\n";
  print "Info:	Similar to the linux 'split' function. Different in that it\n";
  print "	creates random, balanced lists\n";
  exit 1;
}

my ($list, $num_splits, $dir_out) = @ARGV;

my @lines;
open LIST, "$list" or die "Can't open '$list' for reading!\n";
while(<LIST>) {
  chomp;
  push @lines,$_;
}
close(LIST);

my @shuffled = shuffle(@lines);

my %lines_per_fold;

my $fold = 1;
foreach my $line (@shuffled) {
  push @{$lines_per_fold{$fold}},$line;
  $fold += 1;
  if ($fold > $num_splits) {
    $fold = 1;
  }
}

my @sorted = sort keys %lines_per_fold;
foreach $fold (@sorted) {
  open FOLD, ">$dir_out/$fold.lst" or die "Can't open '$dir_out/$fold.lst' for writing!\n";
  foreach my $line (@{$lines_per_fold{$fold}}) {
    print FOLD "$line\n";
  }
  close(FOLD);
}
