// A library of functions for interacting with the FatWatch UI

function saveScreenshot(name) {
	UIALogger.logMessage("capturing: " + name);
	UIATarget.localTarget().delay(1);
	UIATarget.localTarget().captureScreenWithName(name);
	UIATarget.localTarget().delay(1);
}

function tapTabAtIndex(index) {
	var tabBar = UIATarget.localTarget().frontMostApp().mainWindow().tabBar();
	tabBar.buttons()[index].tap();
	UIATarget.localTarget().delay(2);
	UIALogger.logMessage("Switch to Tab: " + tabBar.selectedButton().name());
}

function tapTabLog() { tapTabAtIndex(0); }
function tapTabTrends() { tapTabAtIndex(1); }
function tapTabGoal() { tapTabAtIndex(2); }
function tapTabMore() { tapTabAtIndex(3); }

function scrollTableToBottom() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var tableView = mainWindow.tableViews()[0];
	tableView.scrollDown();
}

function tapNavigationBarButtonLeft() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var navBar = mainWindow.navigationBar();
	var button = navBar.leftButton();
	UIALogger.logDebug("about to tap left button: " + button.name());
	button.tap();
	button.waitForInvalid();
}

function tapNavigationBarButtonRight() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var navBar = mainWindow.navigationBar();
	var button = navBar.rightButton();
	UIALogger.logDebug("about to tap right button: " + button.name());
	button.tap();
	button.waitForInvalid();
}

tapNavigationBarButtonSave = tapNavigationBarButtonRight
tapNavigationBarButtonCancel = tapNavigationBarButtonLeft
tapNavigationBarButtonBack = tapNavigationBarButtonLeft

function enableSwitchForTableRowWithName(name) {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var tableView = mainWindow.tableViews()[0];
	var cell = tableView.cells().firstWithName(name);
	var control = cell.switches()[0];
	if (control.value() == 1) {
		UIALogger.logWarning("Did not reset defaults; " + name + " already enabled.");
		control.tap();
		UIATarget.localTarget().delay(1);
	}
	control.tap();
	control.waitForInvalid();
}

function switchOnComputeBMI() {
	enableSwitchForTableRowWithName("Compute BMI");
}

function switchOnPasscode() {
	enableSwitchForTableRowWithName("Require Passcode");
}

function tapTableRowWithName(name) {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var tableView = mainWindow.tableViews()[0];
	var cell = tableView.cells().firstWithName(name);
	UIALogger.logMessage("about to tap cell: " + cell.name());
	cell.tap();
	cell.waitForInvalid();
}

function tapTableRowImportExportViaWiFi() {
	tapTableRowWithName("Import/Export via Wi-Fi");
}

function tapTableRowExportViaEmail() {
	tapTableRowWithName("Export via Email");
	UIATarget.localTarget().delay(4);
}

function tapTableRowMarks() {
	tapTableRowWithName("Marks");
	UIATarget.localTarget().delay(2);
}

function tapButtonWithName(name) {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var button = mainWindow.buttons().firstWithName(name);
	button.tap();
}

function tapMarksButtonGold() {
	tapButtonWithName("Gold Mark");
}

function tapButtonUseForExerciseLadder() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var scrollView = mainWindow.scrollViews()[0];
	var button = scrollView.buttons().firstWithName("Use for Exercise Ladder");
	button.tap();
}

function tapActionSheetButtonDeleteDraft() {
	var actionSheet = UIATarget.localTarget().frontMostApp().actionSheet();
	var button = actionSheet.buttons()[0];
	button.tap();
	button.waitForInvalid();
}

function tapActionSheetButtonCancel() {
	var actionSheet = UIATarget.localTarget().frontMostApp().actionSheet();
	var button = actionSheet.buttons()[2];
	button.tap();
	button.waitForInvalid();
}

function tapTableRowGoalWeight() {
	tapTableRowWithName("Goal Weight");
}

function clearGoalIfNeeded() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var deleteButton = mainWindow.navigationBar().leftButton();
	if (deleteButton.isEnabled()) {
		deleteButton.tap();
		UIATarget.localTarget().delay(1);
		var sheet = UIATarget.localTarget().frontMostApp().actionSheet();
		var confirmButton = sheet.buttons()[0];
		confirmButton.tap();
		confirmButton.waitForInvalid();
	}
}

function pickGoalWeight() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var picker = mainWindow.pickers()[0];
	var wheel = picker.wheels()[0];
	wheel.dragInsideWithOptions({startOffset:{x:0.5,y:0.05}, endOffset:{x:0.5,y:0.95}});
	wheel.dragInsideWithOptions({startOffset:{x:0.5,y:0.05}, endOffset:{x:0.5,y:0.95}});
	UIATarget.localTarget().delay(2);
}

function tapTrendsButtonRate() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var button = mainWindow.elements().firstWithName("Show Equivalents");
	button.tap();
	button.waitForInvalid();
}

function tapLogInfoButton() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var navBar = mainWindow.navigationBar();
	var button = navBar.buttons()[0];
	button.tap();
}

function tapTableRowLast() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var tableView = mainWindow.tableViews()[0];
	var visibleCells = tableView.visibleCells();
	var cell = visibleCells[visibleCells.length - 1];
	UIALogger.logMessage("about to tap cell: " + cell.name());
	cell.tap();
	cell.waitForInvalid();
}

function tapSegmentedControlAtSegmentIndex(control, index) {
	var count = control.buttons().length;
	var x = (index + 0.5) / count;
	var x1 = x - 0.01;
	var x2 = x + 0.01;
	UIALogger.logMessage("For i=" + index + " dragging around x=" + x);
	control.dragInsideWithOptions({startOffset:{x:x1,y:0.5},endOffset:{x:x2,y:0.5}});
	UIATarget.localTarget().delay(1);
	UIALogger.logMessage("Switched to Segment: " + control.selectedButton().name());
}

function tapWeighInType(index) {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var control = mainWindow.segmentedControls()[0];
	tapSegmentedControlAtSegmentIndex(control, index);
}

function tapWeighInTypeWeightAndFat() { tapWeighInType(0); }
function tapWeighInTypeWeightOnly() { tapWeighInType(1); }
function tapWeighInTypeNone() { tapWeighInType(2); }

function tapWeighInMarkBlue() { tapButtonWithName("Blue Mark"); }
function tapWeighInMarkRed() { tapButtonWithName("Red Mark"); }
function tapWeighInMarkGreen() { tapButtonWithName("Green Mark"); }
function tapWeighInMarkGold() { tapButtonWithName("Gold Mark"); }

function tapWeighInNote() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var noteField = mainWindow.textViews()[0];
	noteField.tap();
}

function setWeighInNoteText(text) {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var noteField = mainWindow.textViews()[0];
	noteField.setValue(text);
}

function typeReturnKey() { // unused
	var keyboard = UIATarget.localTarget().frontMostApp().keyboard();
	keyboard.buttons().firstWithName("return").tap();
	keyboard.waitForInvalid();
}

function tapToolbarButtonSave() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var button = mainWindow.toolbar().buttons().firstWithName("Save");
	button.tap();
	button.waitForInvalid();
}

function tapRungIncrease() { // unused
	UIATarget.localTarget().delay(2);
	var navBar = UIATarget.localTarget().frontMostApp().mainWindow().navigationBar();
	var button = navBar.segmentedControls()[0].buttons()[0];
	UIALogger.logDebug("Button: " + button.name());
	for (var i = 0; i < 7; i++) {
		button.tap();
		UIATarget.localTarget().delay(0.5);
	}
}

function rotateDeviceLandscape() {
	var target = UIATarget.localTarget();
	target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPERIGHT);
	target.delay(2);
}

function rotateDevicePortrait() {
	var target = UIATarget.localTarget();
	target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
	target.delay(2);
}

function tapChartSpanAtIndex(index) {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var toolbar = mainWindow.toolbar();
	var control = toolbar.segmentedControls()[0];
	tapSegmentedControlAtSegmentIndex(control, index);
}

function tapChartSpanMonth() { tapChartSpanAtIndex(0); }
function tapChartSpanQuarter() { tapChartSpanAtIndex(1); }
function tapChartSpanYear() { tapChartSpanAtIndex(2); }
function tapChartSpanAll() { tapChartSpanAtIndex(3); }
function tapChartSpanBrowse() { tapChartSpanAtIndex(4); }

function tapChartTypeAtIndex(index) {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var toolbar = mainWindow.toolbar();
	var control = toolbar.segmentedControls()[1];
	tapSegmentedControlAtSegmentIndex(control, index);
}

function tapChartTypeTotal() { tapChartTypeAtIndex(0); }
function tapChartTypeFat() { tapChartTypeAtIndex(1); }

function tapChartActionButton() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var toolbar = mainWindow.toolbar();
	toolbar.buttons().firstWithName("Action").tap();
}
