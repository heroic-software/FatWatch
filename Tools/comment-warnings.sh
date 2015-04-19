#
# comment-warnings.sh
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

KEYWORDS="TODO:|\?\?\?:"
find ${SRCROOT} \( -name "*.h" -or -name "*.m" \) -print0 | \
    xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | \
    perl -p -e "s/($KEYWORDS)/ warning: \$1/"

KEYWORDS="FIXME:|\!\!\!:"
find ${SRCROOT} \( -name "*.h" -or -name "*.m" \) -print0 | \
    xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | \
    perl -p -e "s/($KEYWORDS)/ error: \$1/"
