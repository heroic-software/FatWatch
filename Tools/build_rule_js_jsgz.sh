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
