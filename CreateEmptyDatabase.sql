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
