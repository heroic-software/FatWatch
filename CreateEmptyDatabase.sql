CREATE TABLE metadata (
	name TEXT UNIQUE ON CONFLICT REPLACE,
	value
);
-- WeightUnit: 1 = lbs, 2 = kgs
-- EarliestMonth

CREATE TABLE weight (
	monthday INTEGER PRIMARY KEY,
	measuredValue REAL,
	trendValue REAL,
	flag INTEGER,
	note TEXT
);

-- index values for faster min/max computation
CREATE INDEX measuredValue_index ON weight (measuredValue);

-- import test data
/*
.read TestData.sql
INSERT INTO metadata VALUES ("WeightUnit", 1);
VACUUM;
*/