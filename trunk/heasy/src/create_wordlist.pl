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
  print "Usage: ./create_wordlist.pl <in:trans_list> <out:word_list>\n\n";
  print "	<trans_list>	- one filename per line\n";
  print "	<word_list> 	- destination filename for wordlist\n";
  print "\n";
  exit 1;
}

my ($trans_list, $word_list) = @ARGV;

my @tokens;
my %words;

open LIST, "$trans_list" or die "Can't open '$trans_list' for reading!\n";
while(<LIST>) {
  chomp;
  my $line;
  open TRANS, "$_" or die "Error opening file '$_'";
  while(<TRANS>) {
    chomp($line = $_);
    @tokens = split(/\s+/,$line);
    foreach my $token (@tokens) {
      $words{$token} += 1;
    }
  }
  close(TRANS);
}
close(LIST);

open WORDS, ">$word_list" or die "Can't open '$word_list' for writing!\n";
foreach my $word (sort keys %words) {
  printf WORDS "%s\n", $word;
}
close(WORDS);
