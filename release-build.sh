#!/bin/sh

# Creates a RAM disk device, formats, then mounts it.
# parameters: size in megabytes
create_ram_disk() {
	local RAMDISK_SIZE_MB=$1
	local RAMDISK_SECTORS=$((2048 * $RAMDISK_SIZE_MB))
	RAMDISK_DEVICE=`hdiutil attach -nomount ram://$RAMDISK_SECTORS`
	RAMDISK_PATH=`mktemp -d /tmp/ramdisk.XXXXXX`
	newfs_hfs $RAMDISK_DEVICE # format as HFS+
	mount -t hfs $RAMDISK_DEVICE $RAMDISK_PATH
	df -h $RAMDISK_PATH # report on disk usage
}

# Destroys the RAM disk created by create_ram_disk
# parameters: none
destroy_ram_disk() {
	echo "Destroying $RAMDISK_DEVICE"
	df -h $RAMDISK_PATH # report on disk usage
	umount -f $RAMDISK_DEVICE
	hdiutil detach $RAMDISK_DEVICE
	rmdir $RAMDISK_PATH
}

# Performs a build on the RAM disk
# parameters: target name, configuration name
build_app() {
	local XCODE_TARGET=$1
	local XCODE_CONFIGURATION=$2
	
	local BUILD_NAME="$XCODE_TARGET-$XCODE_CONFIGURATION"
	local APP_PATH="$RAMDISK_PATH/Build/Products/$XCODE_CONFIGURATION-iphoneos/$XCODE_TARGET.app"
	local ZIP_PATH="$DESTINATION_PATH/$BUILD_NAME.zip"

	echo "Building $XCODE_TARGET ($XCODE_CONFIGURATION)"
	xcodebuild \
			-configuration $XCODE_CONFIGURATION \
			-target $XCODE_TARGET \
			build \
			BUILD_ID=$BUILD_ID \
			OBJROOT=$RAMDISK_PATH/Build/Intermediate \
			SYMROOT=$RAMDISK_PATH/Build/Products \
			DEBUG_INFORMATION_FORMAT=dwarf \
			> "$DESTINATION_PATH/$BUILD_NAME.txt"
}


extract_mobileprovision() {
	local XCODE_TARGET=$1
	local XCODE_CONFIGURATION=$2

	local PRODUCTS_PATH="$RAMDISK_PATH/Build/Products/$XCODE_CONFIGURATION-iphoneos"
	local PROVISION_PATH="$PRODUCTS_PATH/$XCODE_TARGET.mobileprovision"
	
	cp $PRODUCTS_PATH/*.app/embedded.mobileprovision $PROVISION_PATH
}


make_zip() {
	local XCODE_TARGET=$1
	local XCODE_CONFIGURATION=$2

	local PRODUCTS_PATH="$RAMDISK_PATH/Build/Products/$XCODE_CONFIGURATION-iphoneos"
	local BUILD_NAME="$XCODE_TARGET-$BUILD_ID-$XCODE_CONFIGURATION"
	local ZIP_PATH="$DESTINATION_PATH/$BUILD_NAME.zip"

	if [ -e $ZIP_PATH ]; then rm $ZIP_PATH; fi
	# iTunes Connect will not accept archives created by the zip command.
	ditto -c -k -v --sequesterRsrc $PRODUCTS_PATH $ZIP_PATH
}



# Build Date `date -u +"%Y-%m-%d %H:%M:%S"`
# svnversion => "198:220M"
# Globals: RAMDISK_PATH, BUILD_ID, DESTINATION_PATH

svn update
SVNVERSION=`svnversion -n`
DATETIME=`perl -e "print sprintf('%X', time);"`
BUILD_ID="${DATETIME}R${SVNVERSION}"

DESTINATION_PATH=$PWD/Build-$BUILD_ID
if [ -e $DESTINATION_PATH ]; then
	echo "$DESTINATION_PATH exists; nothing to do."
	exit
fi

echo "Creating $DESTINATION_PATH"
mkdir -p $DESTINATION_PATH

create_ram_disk 10

build_app FatWatch Evaluation
extract_mobileprovision FatWatch Evaluation
make_zip FatWatch Evaluation

build_app FatWatch Distribution
make_zip FatWatch Distribution

destroy_ram_disk
exit
