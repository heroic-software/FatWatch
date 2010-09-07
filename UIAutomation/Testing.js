// Basic test harness functions

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
