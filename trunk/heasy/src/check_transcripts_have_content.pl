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

# Confirm that the transcription has content, and at most one line

if ((@ARGV + 0) != 1) {
  print "./check_transcripts_have_content.pl <in:file_list>\n\n";
  print "	<file_list>	- file with list of transcription files\n";
  exit 1;
}

my $list = $ARGV[0];

open LIST, "$list" or die "Can't open '$list' for reading!\n";
while(<LIST>) {
  chomp;
  my $num_lines;
  my $file = $_;
  open TRANS, "$file" or die "Can't open '$file' for reading!\n";
  while (<TRANS>) {
    chomp;
    $num_lines += 1;
    $_ =~ s/\s+//g;
    if ($_ =~ /^$/) {
      print "ERROR: <$file> is empty\n"; 
    }
  }
  close(TRANS);
  if ($num_lines > 1) {
    print "ERROR: <$file> has <$num_lines> lines\n"; 
  }
}
close(LIST);
