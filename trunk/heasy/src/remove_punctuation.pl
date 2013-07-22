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
  print "Usage: ./remove_punctuation.pl <in:file_list> <in:punc_list>\n\n";
  print "	<file_list>	- format per line:<file in> <file out>\n";
  print "                   	- file in should have only one line of text\n";
  print "	<punc_list> 	- format per line:\"change from\";\"change to\"\n";
  exit 1;
}

my ($file_list, $file_punc) = @ARGV;

my %punctuation;
my @original_order;

open PUNC, "$file_punc" or die "Can't open '$file_punc' for reading!\n";
while(<PUNC>) {
  chomp;
  /^\"([[:print:]]+)\";\"([[:print:]]*)\"\s*$/;
  $punctuation{$1} = $2;
  push @original_order, $1;
}
close(PUNC);

my @files;
open LIST, "$file_list" or die "Can't open '$file_list' for reading!\n";
while(<LIST>) {
  chomp;
  @files = split(/\s+/,$_);

  my $line;
  my @lines;
  open FILE_IN, "$files[0]" or die "Can't open '$files[0]' for reading!\n";
  while(<FILE_IN>) {
    chomp($line = $_);
    
    # remove control characters
    $line =~ s/[[:cntrl:]]/ /g;

    foreach my $punc (@original_order) {
      $line =~ s/\Q$punc\E/$punctuation{$punc}/g;
    }
    
    $line =~ s/\s+/ /g;
    $line =~ s/(^\s+|\s+$)//g;
    push @lines,$line;
  }
  close(FILE_IN);

  open FILE_OUT, ">$files[1]" or die "Can't open '$files[1]' for writing!\n";
  foreach $line (@lines) {
    printf FILE_OUT "%s\n", $line;
  }
  close(FILE_OUT);
}
close(LIST);
