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

# Make sure that every word has at least one phoneme in its pronunciation

if ((@ARGV + 0) != 1) {
  print "./check_valid_dict_pronunciations.pl <in:dict>\n\n";
  print "	<dict>		- pronunciation dictionary (htk format)\n";
  exit 1;
}

my $dictionary = $ARGV[0];

my %dict;
my @tokens;
my $pron;
my $result = 0;

open DICT, "$dictionary" or die "Can't open '$dictionary' for reading!\n";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  if (@tokens == 0) {
    print "ERROR: <$word> has invalid pronunciation\n";
    $result = 1;
  }
  $pron = join " ",@tokens;
  $dict{$word} = $pron;
}
close(DICT);

exit $result;

