/*
 * Testing.js
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

function assertEquals(expected, received, message) {
	if (expected != received) {
		if (! message) {
			message = "Expected " + expected + " but received " + received;
		}
		throw message;
	}
}

function assertTrue(expression, message) {
	if (! expression) {
		if (! message) {
			message = "Assertion failed";
		}
		throw message;
	}
}

function assertFalse(expression, message) {
	assertTrue(!expression, message);
}

function assertNotNil(expression, message) {
	if (expression == null || expression.toString() == "[object UIAElementNil]") {
		if (! message) message = "Expected non-nil object";
		throw message;
	}
}
