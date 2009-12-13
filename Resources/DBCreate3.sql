BEGIN EXCLUSIVE;

CREATE TABLE metadata (
	name TEXT UNIQUE ON CONFLICT REPLACE,
	value
);

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
CREATE INDEX trendWeight_index ON months (outputTrendWeight);
CREATE INDEX trendFat_index ON months (outputTrendFat);

INSERT INTO metadata VALUES ("dataversion", 3);

END;
