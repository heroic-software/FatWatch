#!/bin/sh

# ResetDefaults.sh
# EatWatch
#
# Created by Benjamin Ragheb on 9/6/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

find "/Users/benzado/Library/Application Support/iPhone Simulator" \
	-name "com.benzado.FatWatch.*.plist" \
	-exec cp -v Defaults.plist "{}" \;
