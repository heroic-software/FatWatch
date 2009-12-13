BEGIN EXCLUSIVE;

CREATE TABLE days (
	monthday INTEGER PRIMARY KEY,
	scaleWeight REAL,
	scaleFat REAL,
	flag INTEGER,
	rung INTEGER,
	note TEXT
);
CREATE INDEX scaleWeight_index ON days (scaleWeight);
CREATE INDEX scaleFat_index ON days (scaleFat);

CREATE TABLE months (
	month INTEGER PRIMARY KEY,
	outputTrendWeight REAL,
	outputTrendFat REAL
);

INSERT INTO days (monthday,scaleWeight,flag,note)
	SELECT monthday,measuredValue,flag,note
	FROM weight;

CREATE TEMPORARY TABLE scratch (
	month INTEGER PRIMARY KEY,
	monthday INTEGER
);

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

INSERT INTO metadata VALUES ('dataversion', 3);

END;
VACUUM;
