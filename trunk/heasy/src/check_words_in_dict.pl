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

# Confirm that every word in the transcriptions has a corresponding
# pronunciation in the pronunciation dictionary

if ((@ARGV + 0) != 2) {
  print "./check_words_in_dict.pl <in:file_list> <in:dict>\n\n";
  print "	<file_list>	- file with list of transcription files\n";
  print "	<dict>		- pronunciation dictionary (htk format)\n";
  exit 1;
}

my ($list, $dictionary) = @ARGV;

my %dict;
my @tokens;
my $pron;

open DICT, "$dictionary" or die "Can't open '$dictionary' for reading!\n";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  my $word = shift @tokens;
  $pron = join " ",@tokens;
  if (!exists($dict{$word})) {
    $dict{$word} = $pron;
  }
}
close(DICT);

open LIST, "$list" or die "Can't open '$list' for reading!\n";
while(<LIST>) {
  my $flag = 1;
  my $file;
  chomp ($file = $_);
  open FILE, "$file" or die "Can't open '$file' for reading!\n";
  while (<FILE>) {
    chomp;
    @tokens = split(/\s+/,$_);
    foreach my $word (@tokens) {
      if (!exists($dict{$word})) {
        print "ERROR: <$word> not in dict\n";
        $flag = 0;
      }
    }
  }
  close(FILE);
  
  if ($flag == 0) {
    print "FILE: <$file>\n";
  }
}
close(LIST);
