#!/bin/sh

SVN_START_REV=186

RAMDISK_SIZE_MB=10
ZIP_PATH=$PWD

# CREATE RAM DISK

RAMDISK_SECTORS=$((2048 * $RAMDISK_SIZE_MB))
RAMDISK_DEVICE=`hdiutil attach -nomount ram://$RAMDISK_SECTORS`
echo "created ramdisk $RAMDISK_DEVICE"
RAMDISK_PATH=`mktemp -d /tmp/ramdisk.XXXXXX`
newfs_hfs $RAMDISK_DEVICE
mount -t hfs $RAMDISK_DEVICE $RAMDISK_PATH

# BUILD

XCODE_TARGET=FatWatch

do_build() {
	XCODE_CONFIGURATION=$1
	ZIP_FILE_PATH="$ZIP_PATH/$XCODE_TARGET-$XCODE_CONFIGURATION.zip"
	
	xcodebuild \
			-configuration $XCODE_CONFIGURATION \
			-target $XCODE_TARGET \
			build \
			OBJROOT=$RAMDISK_PATH/Build/Intermediate \
			SYMROOT=$RAMDISK_PATH/Build/Products
	if [ -e $ZIP_FILE_PATH ]; then rm $ZIP_FILE_PATH; fi
	APP_PATH=$RAMDISK_PATH/Build/Products/$XCODE_CONFIGURATION-iphoneos/$XCODE_TARGET.app
	ditto -c -k -v --keepParent --sequesterRsrc $APP_PATH $ZIP_FILE_PATH
}

do_build Distribution
do_build Release

# CHANGELOG

SVN_BIN=/usr/local/bin/svn
$SVN_BIN log -r ${SVN_START_REV}:HEAD > $ZIP_PATH/$XCODE_TARGET-Changes.txt

# DISPOSE RAM DISK

umount -f $RAMDISK_DEVICE
hdiutil detach $RAMDISK_DEVICE
rmdir $RAMDISK_PATH
