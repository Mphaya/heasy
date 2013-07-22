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

if ((@ARGV + 0) != 2) {
  print "./add_disambiguation_symbols.pl <in:dict_in> <out:dict_out>\n\n";
  print "	<dict_in>	- raw pronunciation dictionary (htk format)\n";
  print "	<dict_out>	- pronunciation dictionary (htk format) with\n";
  print "			- disambiguation symbols added\n";
  print "\n";
  exit 1;
}

my ($dictionary_in, $dictionary_out) = @ARGV;

my %dict;
my %prons;
my %disamb;
my @tokens;
my $pron;

open DICT, "$dictionary_in" or die "Can't open '$dictionary_in' for reading!\n";
open OUT, ">$dictionary_out" or die "Can't open '$dictionary_out' for writing!\n";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  $pron = join " ", @tokens;
  push @{ $dict{$word} },$pron;

  # TODO(Charl): Come up with a cleaner way to handle SENTSTART and SENTEND
  if ($pron ne "sil") {
    $prons{$pron} += 1;
  } else {
    $prons{$pron} = 1;
  }
  $disamb{"$word"."\t$pron"} = $prons{$pron};
}
close(DICT);

foreach my $wordpron (sort keys %disamb) {
  @tokens = split(/\s+/,$wordpron);
  my $word = shift @tokens;
  $pron = join " ",@tokens;
  if ($prons{$pron} > 1) {
    print OUT "$wordpron #$disamb{$wordpron}\n";
  } else {
    print OUT "$word\t$pron\n";
  }
}
close OUT;
