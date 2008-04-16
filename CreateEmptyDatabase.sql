CREATE TABLE weight (
	month INTEGER,
	day INTEGER,
	measuredValue REAL,
	trendValue REAL,
	flag INTEGER,
	note TEXT
);
CREATE UNIQUE INDEX date ON weight (month, day);

-- Import Test Data
.read TestData.sql
