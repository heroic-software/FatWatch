#!/bin/sh
#
# upload.sh
# Copyright 2015 Heroic Software Inc
#
# This file is part of FatWatch.
#
# FatWatch is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# FatWatch is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
#

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
