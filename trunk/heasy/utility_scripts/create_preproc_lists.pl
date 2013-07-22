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

if ((@ARGV + 0) < 3) {
  print "./create_preproc_lists.pl <in:dir_trans> <in:dir_proc> <out:preproc_list>\n\n";
  print "	<dir_trans>	- directory where transcriptions reside (NB: .txt files!)\n";
  print "	<dir_proc>	- directory where processed .txt will be saved to\n";
  print "	<preproc_list>	- full path to preproc_list.txt\n";
  exit 1;
}

my ($dir_trans, $dir_preproc, $list) = @ARGV;

if (! -d $dir_preproc) {
  print "$dir_preproc doesn't exist! Please create.\n";
  exit 1;
}

my @files = `find $dir_trans -iname "*.txt"`;

my %files;
chomp($dir_preproc=`readlink -f $dir_preproc`);

open LIST, ">$list" or die "Can't open '$list' for writing!\n";

foreach my $file (@files) {
  chomp($file);
  chomp($file=`readlink -f $file`);
  my $basename = basename($file);
  if (exists($files{$basename})) {
    print "WARNING: Non-unique filename encountered! <$basename> Exiting\n";
    close LIST;
    exit 1;
  }
  $files{$basename} = 1;
  print LIST "$file $dir_preproc/$basename\n";
}
close LIST;
