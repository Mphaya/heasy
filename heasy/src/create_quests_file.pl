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

# create a questions file for triphone tying from a monophone list
#
if (@ARGV + 0 != 2) {
  print "./create_quests_file.pl <out:quests_file> <in:monophone_list>\n\n";
  print "	<quests_file>		- htk style questions file\n";
  print "	<monophone_list>	- list of monophones\n";
  exit 1;
}

my ($quest_file, $monophone_list) = @ARGV;

my $ph;
my @elements;
my %monophones;

open MONO_LIST, "$monophone_list" or die "Can't open '$monophone_list' for reading!\n";;
while(<MONO_LIST>) {
  chomp($ph = $_);
  if (($ph ne "sil")&&($ph ne "sp")) {
    $monophones{$ph} = 1;
  }
}
close(MONO_LIST);

open QUESTS, ">$quest_file" or die "Can't open '$quest_file' for writing!\n";

foreach $ph (sort keys %monophones) {
  print QUESTS "QS  \"R_$ph\"\t\t{ *+$ph }\n";
}

foreach $ph (sort keys %monophones) {
  print QUESTS "QS  \"L_$ph\"\t\t{ $ph-* }\n";
}
close(QUESTS);
