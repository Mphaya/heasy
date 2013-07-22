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
use File::Basename;
use open IO => ':encoding(utf8)';

if ((@ARGV + 0) != 2) {
  print "./create_mlf_from_text_files.pl <in:trans_list> <out:mlf>\n\n";
  print "	<trans_list>	- full paths to transcriptions, one file per line\n";
  print "	<mlf>		- full path to mlf to be created\n";
  exit 1; 
}

my ($list, $mlf) = @ARGV;

open MLF, ">$mlf" or die "Can't open '$mlf' for writing!\n";
print MLF "\#\!MLF\!\#\n";

my @tokens;
open LIST, "$list" or die "Can't open '$list' for reading!\n";
while(<LIST>) {
  chomp;
  open TRANS, "$_" or die "Can't open '$_' for reading!\n";
  my $fname = fileparse($_);
  $fname =~ s/\.[[:alnum:]]+$/\.lab/g;
  print MLF "\"*/$fname\"\n";
  while(<TRANS>) {
    chomp;
    $_ =~ s/(^\s+|\s+$)//g;
    @tokens = split(/\s+/,$_);
    foreach my $token (@tokens) {
      if ($token !~ /^[[:digit:]]/) {
        print MLF "$token\n";
      } else {
        print MLF "\"$token\"\n";
      }
    }
  }
  close(TRANS);
  print MLF ".\n";
}
close(LIST);
