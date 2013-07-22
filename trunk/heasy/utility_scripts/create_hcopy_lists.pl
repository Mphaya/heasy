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

if ((@ARGV + 0) != 3) {
  print "./create_hcopy_lists.pl <in:dir_wav> <out:dir_mfc> <out:hcopy_list>\n\n";
  print "	<dir_wav>	- directory where audio files reside\n";
  print "	<dir_mfc>	- directory where mfccs will be saved to\n";
  print "	<hcopy_list>	- full path to hcopy list that will be created for you\n";
  exit 1;
}

my ($dir_wav, $dir_mfc, $list) = @ARGV;

if (! -d $dir_mfc) {
  print "$dir_mfc doesn't exist! Please create.\n";
  exit 1;
}

my @files = `find $dir_wav -iname "*.wav"`;

my %files;
chomp($dir_mfc=`readlink -f $dir_mfc`);

open LIST, ">$list";

foreach my $file (@files) {
  chomp($file);
  chomp($file=`readlink -f $file`);
  my $basename = basename($file);
  $basename =~ s/\.wav$/\.mfc/g;
  if (exists($files{$basename})) {
    print "WARNING: Non-unique filename encountered! <$basename> Exiting\n";
    close LIST;
    exit 1;
  }
  $files{$basename} = 1;
  print LIST "$file $dir_mfc/$basename\n";
}
close LIST;
