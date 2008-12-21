do_setup() {
	TAG_PREFIX=build-
	SVN_PATH_TRUNK=trunk
	SVN_PATH_TAGS=tags
	RAMDISK_SIZE_MB=20
}

do_build() {
	# Create AdHoc version
	make_app FatWatch AdHoc
	copy_mobileprovision FatWatch AdHoc
	make_zip FatWatch AdHoc
	
	# Create AppStore version
	make_app FatWatch AppStore
	make_zip FatWatch AppStore
}
