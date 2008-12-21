# CONFIGURATION DEFAULTS (override in your do_setup function)


TAG_PREFIX=build-
SVN_PATH_TRUNK=trunk
SVN_PATH_TAGS=tags
RAMDISK_SIZE_MB=10
OUTPUT_ROOT=$PWD


# FUNCTIONS


# Fancy echo of a label and a value
function echo_value() {
	local ANSI_BG_GRAY='\E[47m'
	local ANSI_OFF='\E[0m'
	echo -e $1: $ANSI_BG_GRAY$2$ANSI_OFF
}


# Creates a RAM disk device, formats, then mounts it.
function create_ram_disk() {
	local RAMDISK_SECTORS=$((2048 * $RAMDISK_SIZE_MB))
	RAMDISK_DEVICE=`hdiutil attach -nomount ram://$RAMDISK_SECTORS`
	RAMDISK_PATH=`mktemp -d /tmp/ramdisk.XXXXXX`
	newfs_hfs $RAMDISK_DEVICE # format as HFS+
	mount -t hfs $RAMDISK_DEVICE $RAMDISK_PATH
	df -h $RAMDISK_PATH # report on disk usage
}


# Destroys the RAM disk created by create_ram_disk
function destroy_ram_disk() {
	echo_value "Destroying RAM Disk" $RAMDISK_DEVICE
	df -h $RAMDISK_PATH # report on disk usage
	umount -f $RAMDISK_DEVICE
	hdiutil detach $RAMDISK_DEVICE
	rmdir $RAMDISK_PATH
	unset RAMDISK_DEVICE
	unset RAMDISK_PATH
}


# Performs a build on the RAM disk
make_app() {
	local XCODE_TARGET=$1
	local XCODE_CONFIGURATION=$2
	local XCODE_OUTPUT=$OUTPUT_PATH/$1-$2.txt
	
	echo_value "Xcode Output" $XCODE_OUTPUT
	xcodebuild \
			-configuration $XCODE_CONFIGURATION \
			-target $XCODE_TARGET \
			build \
			OBJROOT=$OBJ_ROOT \
			SYMROOT=$SYM_ROOT \
			BUILD_NUMBER=$BUILD_NUMBER \
			DEBUG_INFORMATION_FORMAT=dwarf \
			> "$XCODE_OUTPUT"
			
	# DEBUG_INFORMATION_FORMAT: we don't want to generate a dSYM file
	# Info to think about:
	#   CFBundleVersion = build number
	#   CFBundleShortVersionString = marketing version
}


# Copies the mobileprovision file out of the app package
copy_mobileprovision() {
	local XCODE_TARGET=$1
	local XCODE_CONFIGURATION=$2
	local XCODE_ARCH=iphoneos

	local PRODUCTS_PATH="$SYM_ROOT/$XCODE_CONFIGURATION-$XCODE_ARCH"
	local PROVISION_PATH="$PRODUCTS_PATH/$XCODE_TARGET.mobileprovision"
	
	cp $PRODUCTS_PATH/*.app/embedded.mobileprovision $PROVISION_PATH
}


# Creates a zip of the contents of the build products directory
make_zip() {
	local XCODE_TARGET=$1
	local XCODE_CONFIGURATION=$2
	local XCODE_ARCH=iphoneos

	local PRODUCTS_PATH="$SYM_ROOT/$XCODE_CONFIGURATION-$XCODE_ARCH"
	local BUILD_NAME="$XCODE_TARGET-$BUILD_NUMBER-$XCODE_CONFIGURATION"
	local ZIP_PATH="$OUTPUT_PATH/$BUILD_NAME.zip"

	# use `ditto` because iTunes Connect will not accept archives created `zip`
	ditto -c -k -v --sequesterRsrc $PRODUCTS_PATH $ZIP_PATH
	echo_value "Created Archive" $ZIP_PATH
}


# Determines the Root URL of the Subversion Repository
function determine_svn_url_root() {
	local SVN_ROOT_LINE=`svn info | grep "^Repository Root: "`
	if [ -z "$SVN_ROOT_LINE" ]; then
		exit
	fi
	
	SVN_URL_ROOT=${SVN_ROOT_LINE#Repository Root: }
	SVN_URL_TRUNK=$SVN_URL_ROOT/$SVN_PATH_TRUNK
	SVN_URL_TAGS=$SVN_URL_ROOT/$SVN_PATH_TAGS

	echo_value "Repository Root" $SVN_URL_ROOT
}


# Determines the URL of the next build
function determine_svn_url_build() {
	local LAST_TAG=`svn list $SVN_URL_TAGS | grep "^$TAG_PREFIX" | sort | tail -n 1`
	
	if [ -z "$LAST_TAG" ]; then
		echo_value "Last Tag" "not defined"
		LAST_TAG=${TAG_PREFIX}0000/
	else
		echo_value "Last Tag" $LAST_TAG
	fi
	
	local LAST_TAG_SUFFIX=${LAST_TAG#$TAG_PREFIX}
	local LAST_NUMBER=${LAST_TAG_SUFFIX%/}
	echo_value "Last Number" $LAST_NUMBER
	
	BUILD_NUMBER=`printf "%04d" $((${LAST_NUMBER##*0}+1))`
	echo_value "This Number" $BUILD_NUMBER
	
	SVN_URL_BUILD=$SVN_URL_TAGS/$TAG_PREFIX$BUILD_NUMBER

	svn copy --quiet --message "tagging build $BUILD_NUMBER" --parents \
		$SVN_URL_TRUNK $SVN_URL_BUILD
}


function generate_build() {
	OUTPUT_PATH=$OUTPUT_ROOT/$TAG_PREFIX$BUILD_NUMBER
	if [ -e "$OUTPUT_PATH" ]; then
		echo_value Deleting $OUTPUT_PATH
		rm -rf $OUTPUT_PATH
	fi
	echo_value Creating $OUTPUT_PATH
	mkdir -p $OUTPUT_PATH
	
	create_ram_disk
	SRC_ROOT=$RAMDISK_PATH/Source
	OBJ_ROOT=$RAMDISK_PATH/Intermediate
	SYM_ROOT=$RAMDISK_PATH/Products
	svn export $SVN_URL_BUILD $SRC_ROOT > $OUTPUT_PATH/Files.txt
	cd $SRC_ROOT
	do_build
	cd $OUTPUT_PATH
	destroy_ram_disk
}


function svn_log_by_build() {
	if [ "$1" -lt 1 ]; then
		echo Impossible build number: $1
		exit 1
	fi
	if [ "$2" -lt 1 ]; then
		echo Impossible build number: $2
		exit 1
	fi

	BUILD_NUMBER_A=`printf "%04d" $1`
	exit_on_nonzero_status
	BUILD_NUMBER_B=`printf "%04d" $2`
	exit_on_nonzero_status

	determine_svn_url_root

	SVN_URL_BUILD_A=$SVN_URL_TAGS/$TAG_PREFIX$BUILD_NUMBER_A
	LINE=`svn info $SVN_URL_BUILD_A | grep "^Last Changed Rev:"`
	SVN_REV_A=${LINE#Last Changed Rev: }
	
	SVN_URL_BUILD_B=$SVN_URL_TAGS/$TAG_PREFIX$BUILD_NUMBER_B
	LINE=`svn info $SVN_URL_BUILD_B | grep "^Last Changed Rev:"`
	SVN_REV_B=${LINE#Last Changed Rev: }

	echo_value "Build A" $BUILD_NUMBER_A
	echo_value "Build B" $BUILD_NUMBER_B

	echo_value "Revision A" $SVN_REV_A
	echo_value "Revision B" $SVN_REV_B
	
	svn log --verbose --revision $SVN_REV_A:$SVN_REV_B $SVN_URL_ROOT
}


function echo_usage_and_exit() {
	cat <<USAGE_TEXT;
Usage:
    mkbuild new
        create a new build
    mkbuild N
        recreate build N
    mkbuild log N
        print changes between build N-1 and build N
    mkbuild log N M
        print changes between build N and build M
    mkbuild list
        list all builds in repository
USAGE_TEXT
	exit 2
}


function exit_on_nonzero_status() {
	if [ $? -ne 0 ]; then
		echo_usage_and_exit
	fi
}


# MAIN

source config.sh

do_setup

case "$1" in

list | ls)
	determine_svn_url_root
	svn list $SVN_URL_TAGS
	;;
log)
	if [ -z "$3" ]; then
		svn_log_by_build $(($2 - 1)) $2
	else
		svn_log_by_build $2 $3
	fi
	;;
new)
	determine_svn_url_root
	determine_svn_url_build
	generate_build
	;;
*)
	if [ -z "$1" ]; then
		echo_usage_and_exit
	fi
	BUILD_NUMBER=`printf "%04d" $1`
	exit_on_nonzero_status
	determine_svn_url_root
	echo_value "Rebuilding Number" $BUILD_NUMBER
	SVN_URL_BUILD=$SVN_URL_TAGS/$TAG_PREFIX$BUILD_NUMBER
	generate_build
	;;
esac
