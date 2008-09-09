#!/bin/sh

dns-sd -L "FatWatch (iPhone Simulator)"  _http._tcp > bonjour.txt &
sleep 0.5
FWHOST=`sed -n '$ s/.* at //p' bonjour.txt`
kill `jobs -p` 2> /dev/null
#rm bonjour.txt

# default UTF-8
CSVFILE=$1
ENCODING=4
HOW=replace
# vs HOW=merge

URL=http://${FWHOST}/import

echo Uploading to $URL
curl -F encoding=$ENCODING -F filedata=\@$CSVFILE -F how=$HOW $URL
