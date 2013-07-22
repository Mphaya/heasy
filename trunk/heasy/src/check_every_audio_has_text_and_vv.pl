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

if (@ARGV + 0 != 2) {
  print "./check_every_audio_has_text_and_vv.pl <in:list_audio> <in:list_trans>\n\n";
  print "	<list_audio>	- file with list of audio files\n";
  print "	<list_trans>	- file with list of transcription files\n";
  print "\n";
  exit 1;
}

my ($list_train_audio, $list_train_text) = @ARGV;

my @suffixlist = (".lab", ".txt", ".wav", ".mfc");
my %audio_files;
my %text_files;
my $line;

# TODO: Warning if none of the suffixes match!?
open LIST_TRAIN, "$list_train_audio" or die "Can't open '$list_train_audio' for reading!\n";
while (<LIST_TRAIN>) {
  chomp;
  $line = $_;
  my $tmp_file = fileparse($_, @suffixlist);
  $audio_files{$tmp_file} = $line;
}
close(LIST_TRAIN);

open LIST_TEST, "$list_train_text" or die "Can't open '$list_train_text' for reading!\n";
while (<LIST_TEST>) {
  chomp;
  $line = $_;
  my $tmp_file = fileparse($_, @suffixlist);
  $text_files{$tmp_file} = $line;
}
close(LIST_TEST);

# Check that every audio file has a transcription
foreach my $audio_file (sort keys %audio_files) {
  if (!exists($text_files{$audio_file})) {
    print "ERROR: <$audio_files{$audio_file}> has no transcription\n";
  }
}

# Check that every text file has audio
foreach my $text_file (sort keys %text_files) {
  if (!exists($audio_files{$text_file})) {
    print "ERROR: <$text_files{$text_file}> has no audio\n";
  }
}
