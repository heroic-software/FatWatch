#
# build_rule_js_jsgz.sh
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

SOF=${DERIVED_FILES_DIR}/${INPUT_FILE_REGION_PATH_COMPONENT}${INPUT_FILE_NAME}.gz

JSC=/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc
JSHINT=/usr/local/jshint/jshint.js
DRIVER=${PROJECT_DIR}/Tools/jshint-driver.js

if [ ! -x $JSC ]; then
    echo "error: can't find jsc executable"
    exit 1
fi

if [ ! -e $JSHINT ]; then
    echo "error: expecting JSHint at path ${JSHINT}"
    exit 1
fi

if [ ! -e $DRIVER ]; then
    echo "error: driver missing ${DRIVER}"
    exit 1
fi

sed 'i\
.' $INPUT_FILE_PATH | $JSC $JSHINT $DRIVER -- $INPUT_FILE_PATH

gzip -c -9 $INPUT_FILE_PATH > $SOF
