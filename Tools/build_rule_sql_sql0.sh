SOF=${DERIVED_FILES_DIR}/${INPUT_FILE_REGION_PATH_COMPONENT}${INPUT_FILE_BASE}.sql0
(egrep -v "(^-- )|(^ *$)" $INPUT_FILE_PATH; perl -e "print chr(0);") >> $SOF
