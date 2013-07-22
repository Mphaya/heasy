#!/bin/bash
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

echo "Creating a grapheme dictionary dicts/english.graph.dict"

cat data/texts/* | tr ' ' '\n' | sort -u > wrd.lst

rm -f dicts/english.graph.dict
while read line; do
	pron=`echo $line | grep -o -P '.' | tr '\n' ' ' | sed "s: '::g;s:\s\+$::g"`
	echo -e "$line\t$pron" >> dicts/english.graph.dict
done < wrd.lst

rm wrd.lst

