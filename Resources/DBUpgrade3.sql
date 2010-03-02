BEGIN EXCLUSIVE;

-- New Tables

CREATE TABLE days (
	monthday INTEGER PRIMARY KEY,
	scaleWeight REAL,
	scaleFatWeight REAL,
	flag0 INTEGER,
	flag1 INTEGER,
	flag2 INTEGER,
	flag3 INTEGER,
	note TEXT
);

CREATE TABLE months (
	month INTEGER PRIMARY KEY,
	outputTrendWeight REAL,
	outputTrendFatWeight REAL
);

CREATE TABLE equivalents (
	id INTEGER PRIMARY KEY,
	section INTEGER,
	row INTEGER,
	name TEXT,
	unit TEXT,
	value REAL
);

-- Migrate Data

INSERT INTO days (monthday,scaleWeight,flag0,note)
	SELECT monthday,measuredValue,flag,note
	FROM weight;

CREATE TEMPORARY TABLE scratch (
	month INTEGER PRIMARY KEY,
	monthday INTEGER
);

-- build table of last day of each month
INSERT INTO scratch (month,monthday)
	SELECT
		CAST(monthday/32 AS INTEGER) AS month,
		MAX(monthday)
	FROM weight
	WHERE trendValue IS NOT NULL
	GROUP BY month;

INSERT INTO months (month,outputTrendWeight)
	SELECT
		month, trendValue
	FROM scratch
	JOIN weight ON (weight.monthday = scratch.monthday);

DROP TABLE scratch;

DROP TABLE weight;

-- Create Indexes

CREATE INDEX scaleWeightIndex ON days (scaleWeight);
CREATE INDEX scaleFatWeightIndex ON days (scaleFatWeight);
CREATE INDEX flag0Index ON days (flag0);
CREATE INDEX flag1Index ON days (flag1);
CREATE INDEX flag2Index ON days (flag2);
CREATE INDEX flag3Index ON days (flag3);

CREATE INDEX trendWeightIndex ON months (outputTrendWeight);
CREATE INDEX trendFatWeightIndex ON months (outputTrendFatWeight);

CREATE INDEX orderIndex ON equivalents (section,row);

INSERT INTO metadata VALUES ('dataversion', 3);

END;
VACUUM;
