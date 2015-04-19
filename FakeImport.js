/*
 * FakeImport.js
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

var FatWatchImport = {
	"columns":["TheDate",
			   "ScaleReading",
			   "FAT_RATIO",
			   "Message",
			   "DidExercise",
			   "Beer"],
	"samples":[["2001-01-01","2001-01-02","2001-01-03"],
			   ["185.2","185.4","186.1"],
			   ["0.24","0.25","0.24"],
			   ["nothing today","grapes"],
			   ["1","0","1"],
			   ["0","2","1"]],
	"importDefaults":{
		"importDate":1,
		"importWeight":2,
		"importFat":3,
		"importNote":4,
		"importFlag0":5,
		"importFlag1":6
	}
};
