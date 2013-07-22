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

echo "Cleaning text using experiment_template/PREPROC.sh"

# Create a HTK-style scp file
mkdir -p data/texts
TEXTS_PATH=`readlink -f data/texts | tr -d '\n'`
TRANS_PATH=`readlink -f data/ASR.Lwazi.Eng.1.0/transcriptions | tr -d '\n'`
find $TRANS_PATH -type f -iname '*.txt' | sort > 1.lst

cat 1.lst | awk -F '/' -v x=$TEXTS_PATH/ {'print x$NF'} > 2.lst
paste 1.lst 2.lst > data/text.scp

rm 1.lst 2.lst

# Create a punctuation file to clean the Lwazi text
cat << EOF > config/punctuation.txt
"[n]";""
"[s]";""
"[um]";""
".";""
";";""
":";""
"=";" "
"+";" "
"{";" "
"}";" "
"[";" "
"]";" "
"(";" "
")";" "
",";""
"?";""
"-";" "
"!";""
""";""
" '";" \'"
EOF

cd experiment_template
./PREPROC.sh ../data/text.scp all_phases
cd ..

