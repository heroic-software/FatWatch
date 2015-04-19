/*
 * FakeValues.js
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

var FatWatch={
	"deviceName":"Ben\u2019s MacBook",
	"deviceModel":"MacBook Pro",
	"version":"x.y\u2202",
	"copyright":"FatWatch x.y\u2202 (z) 1977 Heroic Software Inc",
	"dateFormats":[{"value":"y-MM-dd",
				   "label":"2009-12-14"},
				   {"value":"M/d/yy",
					"label":"12/14/09"}],
	"weightFormats":[{"value":"0", "label":"pounds (lb)"},
					 {"value":"1", "label":"kilograms (kg)"},
					 {"value":"2", "label":"grams (g)"}],
	"fatFormats":[{"value":"0", "label":"percent (0%&ndash;100%)"},
				  {"value":"1", "label":"ratio (0.0&ndash;1.0)"}],
	"exportDefaults":{
		"exportDate":true,
		"exportDateName":"Date",
		"exportDateFormat":"y-MM-dd",
		"exportWeight":true,
		"exportWeightName":"Weight",
		"exportWeightFormat":"1",
		"exportTrendWeight":false,
		"exportTrendWeightName":"Trend",
		"exportFat":false,
		"exportFatName":"BodyFat",
		"exportFatFormat":"0",
		"exportFlag0":true,
		"exportFlag0Name":"Checkmark",
		"exportFlag1":true,
		"exportFlag1Name":"Checkmark2",
		"exportFlag2":false,
		"exportFlag2Name":"Checkmark3",
		"exportFlag3":true,
		"exportFlag3Name":"Checkmark4",
		"exportNote":true,
		"exportNoteName":"Note"
	}
};