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


# Author: Neil Kleynhans (ntkleynhans@csir.co.za)

if ((@ARGV + 0) != 2) {
  print "Usage: ./check_feature_obs.pl <in:scp_file> <par:min_obs>\n\n";
  print "	<scp_file>	- file containg list of parameter files\n";
  print "	<min_obs> 	- minimum number of observations\n";
  print "\n";
  exit 1;
}

my ($SCP_FILE, $MIN_OBS) = @ARGV;

open DAT, "$SCP_FILE" or die "Could not open file: '$SCP_FILE' for reading!\n";
@raw_data=<DAT>;

foreach $pFile (@raw_data) {
  chomp($pFile);
  $cmd="HList -t -z $pFile | grep 'Num Samples' | awk {'print \$3'}";
  $result=`$cmd`;
  if ($result < $MIN_OBS) {
    print "WARNING: $pFile does not surpass the minimum required number of observations($MIN_OBS): $result\n"
  }
}

