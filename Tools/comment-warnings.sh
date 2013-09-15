KEYWORDS="TODO:|\?\?\?:"
find ${SRCROOT} \( -name "*.h" -or -name "*.m" \) -print0 | \
    xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | \
    perl -p -e "s/($KEYWORDS)/ warning: \$1/"

KEYWORDS="FIXME:|\!\!\!:"
find ${SRCROOT} \( -name "*.h" -or -name "*.m" \) -print0 | \
    xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | \
    perl -p -e "s/($KEYWORDS)/ error: \$1/"
