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
# parameters: target name, configuration name, zip file destination
do_build() {
	local XCODE_TARGET=$1
	local XCODE_CONFIGURATION=$2
	local DESTINATION_PATH=$3
	
	local BUILD_NAME="$XCODE_TARGET-$XCODE_CONFIGURATION"
	local APP_PATH="$RAMDISK_PATH/Build/Products/$XCODE_CONFIGURATION-iphoneos/$XCODE_TARGET.app"
	local ZIP_PATH="$DESTINATION_PATH/$BUILD_NAME.zip"

	echo "Building $XCODE_TARGET ($XCODE_CONFIGURATION)"
	xcodebuild \
			-configuration $XCODE_CONFIGURATION \
			-target $XCODE_TARGET \
			build \
			OBJROOT=$RAMDISK_PATH/Build/Intermediate \
			SYMROOT=$RAMDISK_PATH/Build/Products \
			> "$DESTINATION_PATH/$BUILD_NAME.txt"

	if [ -e $ZIP_PATH ]; then rm $ZIP_PATH; fi
	# iTunes Connect will not accept archives created by the zip command.
	ditto -c -k -v --keepParent --sequesterRsrc $APP_PATH $ZIP_PATH
}

# Generates a changelog based on subversion log
generate_changelog_since() {
	local SVN_START_REV=$1
	local DESTINATION_PATH=$2
	local SVN_BIN=/usr/local/bin/svn
	$SVN_BIN log -r ${SVN_START_REV}:HEAD > $DESTINATION_PATH/Changes.txt
}

# Build Date `date -u +"%Y-%m-%d %H:%M:%S"`
# svnversion => "198:220M"

TIMESTAMP=`date -u +"%Y%m%d-%H%M%S"`
DESTINATION_PATH=$PWD/Build-$TIMESTAMP

echo "Creating $DESTINATION_PATH"
mkdir -p $DESTINATION_PATH
create_ram_disk 10
do_build FatWatch Distribution $DESTINATION_PATH
do_build FatWatch Release $DESTINATION_PATH
destroy_ram_disk
generate_changelog_since 219 $DESTINATION_PATH
svnversion > $DESTINATION_PATH/svnversion.txt
exit
