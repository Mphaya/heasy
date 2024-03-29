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
use List::Util 'shuffle';
use POSIX;
use open IO => ':encoding(utf8)';
binmode STDOUT, ":utf8";

if (scalar(@ARGV) < 4) {
  print "Usage: ./create_n_folds.pl <in: mfccs.lst> <in: trans.lst> <par:num_spks> <out:out_dir> [par:srand seed]\n\n";
  print "	Info:	* selects <num_spks> (num_spks/2 males and num_spks/2 females)\n";
  print "		* expects an mfccs and trans list'\n";
  print "		* Assumes all basenames are unique'\n\n";

  print "	<mfccs.lst>	- list of mfccs\n";
  print "	<trans.lst>	- list of transcriptions\n";
  print "	<num_spks>	- number of speakers for evaluation (will be split between males and females)\n";
  print "	<out_dir>	- directory into which lists will be saved\n\n";
  exit 1;
}

my $fn_mfccs  = $ARGV[0];
my $fn_trans  = $ARGV[1];
my $num_spks  = $ARGV[2];
my $dir_out   = $ARGV[3];

if (defined($ARGV[4])) {
  srand($ARGV[4]);
}

if ($num_spks/2.0 != floor($num_spks/2.0)) {
  print "Not an even number of eval speakers!\nExiting...\n";
  exit 1;
}

my %mfccs;
my %trans;
my %gender;
my %basenames;

# -----------------------------------------------------------------------------
# Read the info from the files
# -----------------------------------------------------------------------------

my $line;
open MFCCS, "$fn_mfccs" or die "Can't open '$fn_mfccs' for reading!\n";
open TRANS, "$fn_trans" or die "Can't open '$fn_trans' for reading!\n";
while(<MFCCS>) {
  chomp($line = $_);
  my @tokens = split(/\//,$line);
  my $basename = pop @tokens;
  $basename =~ s/\.[[:alnum:]]*$//g;
  @tokens = split(/\_/,$basename);
  my $spk = $tokens[0];
  my $gnd = $tokens[1];
  $mfccs{$spk}{$basename} = $line;
  $gender{$gnd}{$spk} = 1;
  $basenames{$basename} = 1;
}
close(MFCCS);

while(<TRANS>) {
  chomp($line = $_);
  my @tokens = split(/\//,$line);
  my $basename = pop @tokens;
  $basename =~ s/\.[[:alnum:]]*$//g;
  @tokens = split(/\_/,$basename);
  my $spk = $tokens[0];
  my $gnd = $tokens[1];
  $trans{$spk}{$basename} = $line;
  $gender{$gnd}{$spk} = 1;
  $basenames{$basename} = 1;
}
close(TRANS);

# -----------------------------------------------------------------------------
# Remove all files/speakers not common in all lists
# -----------------------------------------------------------------------------
foreach my $basename (sort keys %basenames) {
  my @tokens = split(/\_/,$basename);
  my $spk = $tokens[0];
  if (!exists($mfccs{$spk}{$basename})) {
    print "Warning: '$basename' not found in audio!\n";
    delete $trans{$spk}{$basename};
    delete $basenames{$basename};
  }

  if (!exists($trans{$spk}{$basename})) {
    print "Warning: '$basename' not found in transcriptions!\n";
    delete $mfccs{$spk}{$basename};
    delete $basenames{$basename};
  }
}

# -----------------------------------------------------------------------------
# Select eval speakers
# -----------------------------------------------------------------------------
my @eval_speakers;
my @non_eval_speakers;
foreach my $gender (sort keys %gender) {
  my @speakers = keys %{ $gender{$gender} };
  my @rand_speakers = shuffle @speakers;

  # Check that there's enough speakers
  if (scalar(@rand_speakers) < $num_spks/2) {
    print "Too few speakers of type '$gender'\n";
    exit 1;
  }

  push @eval_speakers,splice(@rand_speakers,0,$num_spks/2);
  push @non_eval_speakers,@rand_speakers;
}
# -----------------------------------------------------------------------------
# Create output lists
# -----------------------------------------------------------------------------
open AUDIO_EVAL, ">$dir_out/audio_eval.lst" or die "Can't open '$dir_out/audio_eval.lst' for writing!\n";
open TRANS_EVAL, ">$dir_out/trans_eval.lst" or die "Can't open '$dir_out/trans_eval.lst' for writing!\n";
open AUDIO_TRN, ">$dir_out/audio_trn.lst" or die "Can't open '$dir_out/audio_trn.lst' for writing!\n";
open TRANS_TRN, ">$dir_out/trans_trn.lst" or die "Can't open '$dir_out/trans_trn.lst' for writing!\n";

foreach my $spk (@eval_speakers) {
  my @basenames = sort keys %{ $mfccs{$spk} };
  foreach my $basename (@basenames) {
    print AUDIO_EVAL "$mfccs{$spk}{$basename}\n";
    print TRANS_EVAL "$trans{$spk}{$basename}\n";
  }
}

foreach my $spk (@non_eval_speakers) {
  my @basenames = sort keys %{ $mfccs{$spk} };
  foreach my $basename (@basenames) {
    print AUDIO_TRN "$mfccs{$spk}{$basename}\n";
    print TRANS_TRN "$trans{$spk}{$basename}\n";
  }
}
close(AUDIO_EVAL);
close(TRANS_EVAL);
close(AUDIO_TRN);
close(TRANS_TRN);
