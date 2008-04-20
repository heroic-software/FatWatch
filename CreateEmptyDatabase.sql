CREATE TABLE metadata (
	name TEXT UNIQUE ON CONFLICT REPLACE,
	value
);
-- WeightUnit: 1 = lbs, 2 = kgs
-- EarliestMonth

CREATE TABLE weight (
	month INTEGER,
	day INTEGER,
	measuredValue REAL,
	trendValue REAL,
	flag INTEGER,
	note TEXT
);

-- enforce month+day uniqueness
CREATE UNIQUE INDEX month_day_index ON weight (month, day);

-- index values for faster min/max computation
CREATE INDEX measuredValue_index ON weight (measuredValue);
CREATE INDEX trendValue_index ON weight (trendValue);

-- import test data
.read TestData.sql
INSERT INTO metadata VALUES ("WeightUnit", 1);
INSERT INTO metadata SELECT "EarliestMonth", MIN(month) FROM weight;
