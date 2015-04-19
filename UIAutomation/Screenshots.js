/*
 * Screenshots.js
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
    tapButtonWithName("v3.test");
	takeScreenshotsMore();
	takeScreenshotsTrendsAndGoal();
	takeScreenshotsLog();
	takeScreenshotsChart();	
} catch (e) {
	UIALogger.logError(e);
	var mainWindow = UIATarget.localTarget().frontMostApp().mainWindow();
	mainWindow.logElementTree();
}
