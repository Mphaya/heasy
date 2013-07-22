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

# 1. Read in the aligned files
# 2. Write out all filenames occuring in both aligned mlf and list file

if (@ARGV + 0 != 4) {
  print "./prune_list_after_alignment.pl <in:aligned_trn_mlf> <in:aligned_tst_mlf> <in-out:mfc_trn_lst> <in-out:mfc_tst_lst>\n\n";
  print "	<aligned_trn_mlf>	- aligned train mlf\n";
  print "	<aligned_tst_mlf>	- aligned test mlf\n";
  print "	<mfc_trn_lst>		- list of all train mfccs\n";
  print "	<mfc_tst_lst>		- list of all test mfccs\n";
  exit 1;
}

my ($aligned_train_mlf, $aligned_test_mlf, $list_train_file, $list_test_file) = @ARGV;

my @suffixlist = (".lab", ".txt", ".wav", ".mfc");
my %aligned_train_files;
my %aligned_test_files;
my %list_train_files;
my %list_test_files;

open ALIGNED, "$aligned_train_mlf" or die "Can't open '$aligned_train_mlf' for reading!\n";
while (<ALIGNED>) {
  if (/\.lab/) {
    chomp;
    $_ =~ s/\"//g;
    my $tmp_file = fileparse($_, @suffixlist);
    $aligned_train_files{$tmp_file} = 1;
  }
}
close(ALIGNED);

open ALIGNED, "$aligned_test_mlf" or die "Can't open '$aligned_test_mlf' for reading!\n";
while (<ALIGNED>) {
  if (/\.lab/) {
    chomp;
    $_ =~ s/\"//g;
    my $tmp_file = fileparse($_, @suffixlist);
    $aligned_test_files{$tmp_file} = 1;
  }
}
close(ALIGNED);

my $line;

open LIST_TRAIN, "$list_train_file" or die "Can't open '$list_train_file' for reading!\n";
while (<LIST_TRAIN>) {
  chomp;
  $line = $_;
  my $tmp_file = fileparse($_, @suffixlist);
  if (exists($aligned_train_files{$tmp_file})) {
    $list_train_files{$line} = 1;
  }
}
close(LIST_TRAIN);

open LIST_TEST, "$list_test_file" or die "Can't open '$list_test_file' for reading!\n";;
while (<LIST_TEST>) {
  chomp;
  $line = $_;
  my $tmp_file = fileparse($_, @suffixlist);
  if (exists($aligned_test_files{$tmp_file})) {
    $list_test_files{$line} = 1;
  }
}
close(LIST_TEST);

open LIST_TRAIN, ">$list_train_file" or die "Can't open '$list_train_file' for reading!\n";
foreach my $file (sort keys %list_train_files) {
  print LIST_TRAIN "$file\n";
}
close(LIST_TRAIN);

open LIST_TEST, ">$list_test_file" or die "Can't open '$list_test_file' for reading!\n";
foreach my $file (sort keys %list_test_files) {
  print LIST_TEST "$file\n";
}
close(LIST_TEST);
