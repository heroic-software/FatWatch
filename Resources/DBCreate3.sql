BEGIN EXCLUSIVE;

CREATE TABLE metadata (
	name TEXT UNIQUE ON CONFLICT REPLACE,
	value
);

CREATE TABLE days (
	monthday INTEGER PRIMARY KEY,
	scaleWeight REAL,
	scaleFatRatio REAL,
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

CREATE INDEX scaleWeightIndex ON days (scaleWeight);
CREATE INDEX scaleFatRatioIndex ON days (scaleFatRatio);
CREATE INDEX flag0Index ON days (flag0);
CREATE INDEX flag1Index ON days (flag1);
CREATE INDEX flag2Index ON days (flag2);
CREATE INDEX flag3Index ON days (flag3);

CREATE INDEX trendWeightIndex ON months (outputTrendWeight);
CREATE INDEX trendFatWeightIndex ON months (outputTrendFatWeight);

CREATE INDEX orderIndex ON equivalents (section,row);

INSERT INTO metadata VALUES ("dataversion", 3);

END;
