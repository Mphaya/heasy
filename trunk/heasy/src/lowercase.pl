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

if((@ARGV + 0) != 1) {
  print "Usage: ./lowercase.pl <file_list>\n\n";
  print "	<file_list>	- format per line:<file in> <file out>\n";
  print "                  	- file in should have only one line of text\n";
  exit 1;
}

my $file_list = $ARGV[0];

my @files;
open LIST, "$file_list" or die "Can't open '$file_list' for reading!\n";
while(<LIST>) {
  chomp;
  @files = split(/\s+/,$_);

  my $line;
  my $cnt = 0;
  open FILE_IN, "$files[0]" or die "Can't open '$files[0]' for reading!\n";
  while(<FILE_IN>) {
    if ($cnt != 0) {
      print "WARNING! Expected one line per file!\n";
    }
    chomp($line = $_);
    $cnt += 1;
  }
  close(FILE_IN);

  open FILE_OUT, ">$files[1]" or die "Can't open '$files[1]' for writing!\n";
  printf FILE_OUT "%s\n", lc $line;
  close(FILE_OUT);
}
close(LIST);
