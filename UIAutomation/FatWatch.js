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

function tapNavigationBarButtonSave() { tapNavigationBarButtonRight(); }
function tapNavigationBarButtonCancel() { tapNavigationBarButtonLeft(); }
function tapNavigationBarButtonBack() { tapNavigationBarButtonLeft(); }

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

function tapWeighInType(index) {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var control = mainWindow.segmentedControls()[0];
	control.buttons()[index].tap();
	UIATarget.localTarget().delay(2);
	UIALogger.logMessage("Switch to Entry: " + control.selectedButton().name());
}

function tapWeighInTypeWeightAndFat() { tapWeighInType(1); }
function tapWeighInTypeWeightOnly() { tapWeighInType(2); }
function tapWeighInTypeNone() { tapWeighInType(0); }

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
	var button = control.buttons()[index];
	if (button.toString() == "[object UIAElementNil]") {
		throw ("Can't find " + index);
	}
	button.tap();
	UIALogger.logMessage("Span: " + control.selectedButton().name());
}

function tapChartSpanMonth() { tapChartSpanAtIndex(3); }
function tapChartSpanQuarter() { tapChartSpanAtIndex(2); }
function tapChartSpanYear() { tapChartSpanAtIndex(1); }
function tapChartSpanAll() { tapChartSpanAtIndex(4); }
function tapChartSpanBrowse() { tapChartSpanAtIndex(0); }

function tapChartTypeAtIndex(index) {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var toolbar = mainWindow.toolbar();
	var control = toolbar.segmentedControls()[1];
	var button = control.buttons()[index];
	button.tap();
	UIALogger.logMessage("Type: " + control.selectedButton().name());
}

function tapChartTypeTotal() { tapChartTypeAtIndex(1); }
function tapChartTypeFat() { tapChartTypeAtIndex(0); }

function tapChartActionButton() {
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	var toolbar = mainWindow.toolbar();
	toolbar.buttons().firstWithName("Action").tap();
}
