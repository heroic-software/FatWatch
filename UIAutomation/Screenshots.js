// Screenshots: a script to take screenshots of the UI

#import "FatWatch.js"

/*
 Assume:
 Data: loaded
 Passcode: none
 BMI: off
 Goal: none
 Marks: all checks
 Log: Weight & Variance
 Weigh on Launch: off
 Shade Weekends: on
 BMI Zones: on
 Fit Goal on Chart: off
 Registered: yes
 */

function resetPreferences()
{
	var app = UIATarget.localTarget().frontMostApp();
	app.setPreferenceValueForKey(false, "AutoWeighIn");
	app.setPreferenceValueForKey(0, "AuxiliaryInfoType");
	app.setPreferenceValueForKey(false, "EnableLadder");
	app.setPreferenceValueForKey(0, "GoalWeight");
	app.setPreferenceValueForKey({ name: "John Example", email: "john@example.com" }, "RegistrationInfo");
	app.setPreferenceValueForKey(false, "RegistrationReminder");
	app.setPreferenceValueForKey(0, "SelectedTabIndex");
	app.setPreferenceValueForKey(7, "TrendSpanLength");
	app.setPreferenceValueForKey(8, "LastSavedRung");
}

function takeScreenshotsMore()
{
	tapTabMore();
	saveScreenshot("screen_more_menu1");
	switchOnComputeBMI();
	saveScreenshot("screen_more_bmi");
	tapNavigationBarButtonSave();
	tapTableRowMarks();
	saveScreenshot("screen_notes_marks");
	tapMarksButtonGold();
	tapButtonUseForExerciseLadder();
	saveScreenshot("screen_notes_ladder");
	tapNavigationBarButtonBack();
	switchOnPasscode();
	saveScreenshot("screen_passcode_set");
	tapNavigationBarButtonCancel();
	scrollTableToBottom();
	saveScreenshot("screen_more_menu2");
	tapTableRowImportExportViaWiFi();
	saveScreenshot("screen_more_wifi");
	tapNavigationBarButtonBack();
	tapTableRowExportViaEmail();
	saveScreenshot("screen_more_email");
	tapNavigationBarButtonCancel();
	tapActionSheetButtonDeleteDraft();
}

function takeScreenshotsTrendsAndGoal()
{
	tapTabGoal();
	clearGoalIfNeeded();
	saveScreenshot("screen_goal_unset");

	tapTabTrends();
	saveScreenshot("screen_trends_nogoal");
	
	tapTabGoal();
	tapTableRowGoalWeight();
	pickGoalWeight();
	tapNavigationBarButtonSave();
	saveScreenshot("screen_goal");
	
	tapTabTrends();
	tapNavigationBarButtonLeft();
	saveScreenshot("screen_trends");
	tapTrendsButtonRate();
	saveScreenshot("screen_trends_equiv");
	tapNavigationBarButtonBack();
}

function takeScreenshotsLog()
{
	tapTabLog();

	saveScreenshot("screen_log_variance");
	tapLogInfoButton();
	saveScreenshot("screen_log_bmi");
	tapLogInfoButton();
	saveScreenshot("screen_fat_percent");
	tapLogInfoButton();
	saveScreenshot("screen_fat_weight");
	
	tapTableRowLast();
	tapWeighInTypeWeightAndFat();
	tapWeighInMarkBlue();
	setWeighInNoteText("30min on treadmill");
	saveScreenshot("screen_weighin_both");
	tapNavigationBarButtonCancel();
	
	tapTableRowLast();
	tapWeighInTypeWeightOnly();
	tapWeighInMarkRed();
	tapWeighInMarkGold();
	saveScreenshot("screen_notes_rung");
	tapToolbarButtonSave();
	saveScreenshot("screen_weighin_wonly");
	tapNavigationBarButtonCancel();
	
	tapTableRowLast();
	tapWeighInTypeNone();
	tapWeighInMarkGreen();
	setWeighInNoteText("visiting brother");
	saveScreenshot("screen_notes_blank");
	tapWeighInNote();
	saveScreenshot("screen_notes_typing");
	tapNavigationBarButtonCancel();
}

function takeScreenshotsChart()
{
	rotateDeviceLandscape();
	tapChartSpanMonth();
	tapChartTypeTotal();
	saveScreenshot("screen_chart_month_total");
	tapChartTypeFat();
	saveScreenshot("screen_chart_month_fat");
	tapChartSpanQuarter();
	tapChartTypeFat();
	saveScreenshot("screen_chart_quarter_fat");
	tapChartTypeTotal();
	saveScreenshot("screen_chart_quarter_total");
	tapChartSpanYear();
	tapChartTypeFat();
	saveScreenshot("screen_chart_year_fat");
	tapChartTypeTotal();
	saveScreenshot("screen_chart_year_total");
	tapChartSpanAll();
	tapChartTypeFat();
	saveScreenshot("screen_chart_all_fat");
	tapChartTypeTotal();
	saveScreenshot("screen_chart_all_total");
	tapChartActionButton();
	saveScreenshot("screen_chart_actions");
	tapActionSheetButtonCancel();
	
	rotateDevicePortrait();
}

try {
//	takeScreenshotsMore();
	takeScreenshotsTrendsAndGoal();
//	takeScreenshotsLog();
//	takeScreenshotsChart();	
//	resetPreferences();
} catch (e) {
	UIALogger.logError(e);
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	mainWindow.logElementTree();
}

//screen_settings.png
//screen_settings_energy.png
//screen_settings_menu.png
//screen_settings_precision.png
//screen_settings_weight.png
