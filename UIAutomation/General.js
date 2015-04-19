/*
 * General.js
 * Copyright 2015 Heroic Software Inc
 *
 * This file is part of FatWatch.
 *
 * FatWatch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FatWatch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
 */

#import	"Testing.js"
#import "FatWatch.js"

// Setup

var target = UIATarget.localTarget();

target.onAlert = function onAlert(alert) {
	UIALogger.logDebug("Alert!");
	return false; // let default handler dismiss the alert
}

var mainWindow = target.frontMostApp().mainWindow();

// If started with Passcode View, enter code.

if (mainWindow.images().length == 4) {
	UIALogger.logDebug("Dismissing Passcode Entry");
	var field = mainWindow.secureTextFields()[0];
	field.setValue('1111');
	field.waitForInvalid();
}

// If started with Weigh-in View, hit Cancel to close.

var cancelButton = mainWindow.navigationBar().leftButton();
if (cancelButton.name() == "Cancel") {
	UIALogger.logDebug("Dismissing Automatic Weigh-In");
	cancelButton.tap();
	cancelButton.waitForInvalid();
}


/*
	Screenshots to Capture
	
	Assume Initial Conditions:

	Weight: data loaded
	Goal: none set
	BMI: off
	Passcode: off

	Weigh-In
		Weight & Fat, Blue Mark, "30 min on treadmill"
		Weight Only, Red & Gold Mark, ""
		None, Green Mark, "visiting brother"
		None, Green Mark, "visiting brother", note field has focus
			Exercise Ladder, rung 6

	More
		Marks configuration, blue tab selected
		Marks configuration, gold tab selected, ladder enabled

	Log
		Variance
		BMI
		Body Fat Percentage
		Body Fat Weight

	Goal
		goal set

	Trends
		Past Two Weeks, goal set
		Past Year, no goal set
			Energy Equivalency
			
		no goal set
	More, options
	Enter Passcode
	Set Height
	Wi-Fi Import/Export
	Email Export
	Chart
		Quarter, Total
		Month, Fat
		Year, Total
		Year, Fat
		Action Sheet visible

	Settings, main
	Settings, weight unit
	Settings, energy unit
	Settings, scale precision
	Settings, icon
*/







// Log

function testWeighIn() {
	UIALogger.logStart("Weigh-in");
	
	EWWeighInSwitchToType(kSegmentNone);
	mainWindow.logElementTree();
	
	EWWeighInSwitchToType(kSegmentWeightOnly);
	mainWindow.logElementTree();
	
	EWWeighInSwitchToType(kSegmentWeightAndFat);
	mainWindow.logElementTree();
	
	var picker = mainWindow.pickers()[0];
	var mark0 = mainWindow.buttons().firstWithName("Blue Mark");
	var mark1 = mainWindow.buttons().firstWithName("Red Mark");
	var mark2 = mainWindow.buttons().firstWithName("Green Mark");
	var mark3 = mainWindow.buttons().firstWithName("Gold Mark");
	var noteField = mainWindow.textViews()[0];
	
	mark0.tap();
	mark2.tap();
	noteField.setValue("grapes!");
	UIATarget.localTarget().delay(3);
	
	cancelButton = mainWindow.navigationBar().leftButton();
	cancelButton.tap();
	cancelButton.waitForInvalid();
}

function testLog() {
	EWSwitchToTab(kTabLog);
	mainWindow.logElementTree();
	
	var logCells = mainWindow.tableViews()[0].cells();
	var lastCell = logCells[logCells.length - 1];
	lastCell.tap();
	lastCell.waitForInvalid();
	
	testWeighIn();
}

function testTrends() {
	EWSwitchToTab(kTabTrends);
	var navBar = mainWindow.navigationBar();
	var rightBtn = navBar.rightButton();
	while (rightBtn.isEnabled()) { 
		rightBtn.tap();
	}
	var leftBtn = navBar.leftButton();
	do {
		UIALogger.logMessage(mainWindow.navigationBar().name());
		leftBtn.tap();
		UIATarget.localTarget().delay(1);
	} while (leftBtn.isEnabled());
}

function testGoal() {
	EWSwitchToTab(kTabGoal);
	mainWindow.logElementTree();
}

function testMore() {
	EWSwitchToTab(kTabMore);
	mainWindow.logElementTree();
}

function testChart() {
	UIALogger.logStart("Chart");
	var target = UIATarget.localTarget();
	target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPERIGHT);
	target.delay(4);
	target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
}

testLog();
testTrends();
testGoal();
testMore();
testChart();

// http://alexvollmer.com/posts/2010/07/03/working-with-uiautomation/
