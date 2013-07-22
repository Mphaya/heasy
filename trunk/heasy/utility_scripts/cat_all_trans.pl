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

if((@ARGV + 0) != 2) {
  print "Usage: ./cat_all_trans.pl <in:lst_trans> <out:fn_all_trans>\n\n";
  print "	Info:	- Prints all transcriptions from a potentially very long list\n";
  print "		  to a single file\n";
  print "		- Useful for when a list is too long for cat\n\n";
  print "	<lst_trans>	- list of transcription files\n";
  print "	<fn_all_trans>	- single output file containing all transcriptions\n";
  exit 1;
}

my ($lst_trans, $fn_all_trans) = @ARGV;

# Read in and count all transcriptions from file
# -----------------------------------------------------------------------------
my @trans;
open LIST, "$lst_trans" or die "Can't open '$lst_trans' for reading!\n";
while(<LIST>) {
  chomp;
  open TRANS, "$_" or die "Can't open '$_' for reading!\n";
  while (<TRANS>) {
    chomp; 
    $_ = NFC($_);
    push @trans,$_;
  }
  close(TRANS);
}
close(LIST);

# Print transcriptions with counts to file
# -----------------------------------------------------------------------------
open TRANS_OUT, ">$fn_all_trans" or die "Can't open '$fn_all_trans' for writing!\n";
foreach my $term (sort @trans) {
  printf TRANS_OUT "%s\n", $term;
}
close(TRANS_OUT);
