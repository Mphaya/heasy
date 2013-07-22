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

if((@ARGV + 0) != 5) {
  print "Usage: ./select_tst_terms_from_dict.pl <in:test_terms> <in:audio_tst.lst> <in:trans_tst.lst> <out:200_test_audio_tst.lst> <out:200_test_trans_tst.lst>\n\n";
  print "Description:\n";
  print " * if you have a list of terms and want all those filenames for which the transcription corresponds to one of the terms\n";
  exit 1;
}

my ($fn_trans, $fn_audio_tst, $fn_trans_tst, $fn_200_audio_tst, $fn_200_trans_tst) = @ARGV;

# Read all transcriptions from file
# -----------------------------------------------------------------------------
my %terms;
open TRANS, "$fn_trans" or die "Can't open '$fn_trans' for reading!\n";
while (<TRANS>) {
  chomp; 
  $_ = NFC($_);
  $terms{$_} += 1;
}
close(TRANS);

# Read audio from file
# -----------------------------------------------------------------------------
my %audio_files;
my %trans_files;
open AUDIO_IN, "$fn_audio_tst" or die "Can't open '$fn_audio_tst' for reading!\n";
while(<AUDIO_IN>) {
  chomp;
  my @tokens = split(/\//,$_);
  my $fn = pop @tokens;
  $fn =~ s/\.[a-z0-9A-Z]+$//g;
  $audio_files{$fn} = $_;
}
close(AUDIO_IN);

# Print those tst instances which correspond to the test terms to file
# -----------------------------------------------------------------------------
open AUDIO_OUT, ">$fn_200_audio_tst" or die "Can't open '$fn_200_audio_tst' for writing!\n";
open TRANS_IN,  "$fn_trans_tst" or die "Can't open '$fn_trans_tst' for reading!\n";
open TRANS_OUT, ">$fn_200_trans_tst" or die "Can't open '$fn_200_trans_tst' for writing!\n";
while(<TRANS_IN>) {
  chomp;
  my $fn = $_;
  open TRANS, "$fn" or die "Can't open '$fn' for reading!\n";
  my $trans;
  while (<TRANS>) {
    chomp($trans = $_);
  }
  close(TRANS);
  if (exists($terms{$trans})) {
    my @tokens = split(/\//,$fn);
    my $part = pop @tokens;
    $part =~ s/\.[a-z0-9A-Z]+$//g;
    if (!exists($audio_files{$part})) {
      print "ERROR: '$part' not found in '$fn_audio_tst'\n";
      exit 1;
    } 
    print TRANS_OUT "$fn\n";
    printf AUDIO_OUT "%s\n",$audio_files{$part};
  }
}
close(TRANS_IN);
close(TRANS_OUT);
