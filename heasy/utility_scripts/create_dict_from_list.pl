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
use Unicode::Normalize;
use open IO => ':encoding(utf8)';
use open ':std';

if((@ARGV + 0) != 3) {
  print "Usage: ./create_dict_from_list.pl <in:fn_trans> <in:dict> <out:dict>\n\n";
  print "	Info:	Extract pronunciations for all words in a single file\n";
  print "		from a reference dictionary\n\n";
  print "	<fn_trans>	- file with list of transcription files\n";
  print "	<in:dict>	- full pronunciation dictionary (htk format)\n";
  print "	<out:dict>	- reduced pronunciation dictionary (htk format)\n";
  exit 1;
}

my ($fn_trans, $dict_in, $dict_out) = @ARGV;

# Read in all pronunciations
# -----------------------------------------------------------------------------
my %dict_base;
open DICT_IN, "$dict_in" or die "Can't open '$dict_in' for reading!\n";
while(<DICT_IN>) {
  chomp;
  my @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  my $pron = join " ",@tokens;
  push @{$dict_base{$word}},$pron;
}
close(DICT_IN);

# Read all transcriptions from file and find prons
# -----------------------------------------------------------------------------
my %words;
open TRANS, "$fn_trans" or die "Can't open '$fn_trans' for reading!\n";
while (<TRANS>) {
  chomp; 
  $_ = NFC($_);
  my @tokens = split(/\s+/,$_);
  foreach my $word (@tokens) {
    $words{$word} += 1;
  }
}
close(TRANS);

my %dict_new;
foreach my $word (sort keys %words) {
  if (!exists($dict_base{$word})) {
    print "ERROR: '$word' not found in dict:'$dict_in'\n";
    exit 1;
  }

  foreach my $pron (@{$dict_base{$word}}) {
    push @{ $dict_new{$word} }, $pron;
  }
}

# Print new dictionary to file
# -----------------------------------------------------------------------------
open DICT_OUT, ">$dict_out" or die "Can't open '$dict_out' for writing!\n";
foreach my $word (sort keys %dict_new) {
  foreach my $pron (@{$dict_new{$word}}) {
    printf DICT_OUT "%s %s\n",$word,$pron;
  }
}
close(DICT_OUT);
