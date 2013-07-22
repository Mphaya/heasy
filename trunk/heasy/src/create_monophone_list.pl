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

if((@ARGV + 0) < 2) {
  print "Usage: ./create_monophone_list.pl <out:monophone_list> <in:dict1> <in:dict2> ... <in:dictn>\n\n";
  print "	<mono_list>	- full path to list of monophones which will be created\n";
  print "	<dicti>		- any number of dictionaries from which to identify monophones\n";
  print "\n";
  exit 1;
}

my (@dicts) = @ARGV;

my $monophone_list = $dicts[0];
splice(@dicts,0,1);

my $dict;
my $line;
my @elements;
my %monophones;

foreach $dict (@dicts) {
  open FILE, "$dict" or die "Can't open '$dict' for reading!\n";
  while(<FILE>) {
    chomp($line = $_);
    # normalize the line, in unlikely event that some phones encoded
    # inconsistently
    $line = NFC($line);
    @elements = split(/\s+/,$line);

    # remove the word part
    # TODO: we're assuming that the dictionary format is <word ph1 ph2 ... phn> Check?
    shift @elements;
    foreach my $ph (@elements) {
      $monophones{$ph} = 1;
    }
  }
  close(FILE);
}

open MONO, ">$monophone_list" or die "Can't open '$monophone_list' for writing!\n";

foreach my $ph (sort keys %monophones) {
  print MONO "$ph\n";
}
close(MONO);
