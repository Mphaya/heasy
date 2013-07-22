# Author: Charl van Heerden (cvheerden@csir.co.za)
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

# Go through all the transcriptions and the dictionary and check for things
# that are known to break HTK, such ' at the beginning of a word

if ((@ARGV + 0) != 2) {
  print "./check_for_things_that_break_htk.pl <in:file_list> <in:dict>\n\n";
  print "	<file_list>	- file with list of transcription files\n";
  print "	<dict>		- pronunciation dictionary (htk format)\n";
  print "\n";
  exit 1;
}

my ($list, $dictionary) = @ARGV;

my %phoneset;

my @tokens;
my $pron;

open DICT, "$dictionary" or die "Can't open '$dictionary' for reading!\n";
while(<DICT>) {
  chomp;
  @tokens = split(/\s+/,$_);
  # remove the word
  shift @tokens;
  foreach my $ph (@tokens) {
    $phoneset{$ph} += 1;
  }
}
close(DICT);

# Now check for phones that will break HTK
foreach my $ph (sort keys %phoneset) {
  if ($ph =~ /[\\`']/) {
    print "ERROR: <$ph> contains one of [\\`'] which may break HTK\n"
  }

  if ($ph =~ /^[0-9]/) {
    print "ERROR: <$ph> starts with a number. May be problematic for HTK\n";
  }
}

open LIST, "$list" or die "Can't open '$list' for reading!\n";
while(<LIST>) {
  my $flag = 1;
  my $file;
  chomp ($file = $_);
  open TRANS, "$file" or die "Can't open '$file' for reading!\n";
  while (<TRANS>) {
    chomp;
    @tokens = split(/\s+/,$_);
    foreach my $word (@tokens) {
      # Check each word for invalid tokens
      if ($word =~ /^'/) {
        print "ERROR: <$word> should have \\' You can run PREPROC.sh with default arguments to fix.\n";
      }
    }
  }
  close(TRANS);
  
  if ($flag == 0) {
    print "FILE: <$file>\n";
  }
}
close(LIST);
