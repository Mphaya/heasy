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
use open ':std';

if ((@ARGV + 0) != 2) {
  print "./check_words_in_dict.pl <in:file_list> <in-out:dictionary>\n\n";
  print "	<file_list>	- list of transcription files\n";
  print "	<dictionary>	- pronunciation dictionary\n";
  exit 1;
}

my ($list, $dictionary) = @ARGV;

my %dict;
my @tokens;
my $pron;
my %unigrams;

open DICT, "$dictionary" or die "Can't open '$dictionary' for reading!\n";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  $pron = join " ",@tokens;
  push @{ $dict{$word} }, $pron;
}
close(DICT);

# Read the list of transcriptions
open LIST, "$list" or die "Can't open '$list' for reading!\n";
while(<LIST>) {
  my $file;
  chomp ($file = $_);
  # Read each transcription
  open TRANS, "$file" or die "Can't open '$file' for reading!\n";
  while (<TRANS>) {
    chomp;
    @tokens = split(/\s+/,$_);
    foreach my $word (@tokens) {
      if (!exists($dict{$word})) {
        print "ERROR: <$word> not in dict\n";
      }
      $unigrams{$word} += 1;
    }
  }
  close(TRANS);
}
close(LIST);

# print the reduced dictionary to STDOUT
foreach my $word (sort keys %unigrams) {
  foreach my $pron (@{ $dict{$word} }) {
    print "$word\t$pron\n";
  }
}
