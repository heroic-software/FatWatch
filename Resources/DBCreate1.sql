BEGIN EXCLUSIVE;

CREATE TABLE metadata (
	name TEXT UNIQUE ON CONFLICT REPLACE,
	value
);

CREATE TABLE weight (
	monthday INTEGER PRIMARY KEY,
	measuredValue REAL,
	trendValue REAL,
	flag INTEGER,
	note TEXT
);

-- index values for faster min/max computation
CREATE INDEX measuredValue_index ON weight (measuredValue);

INSERT INTO metadata VALUES ("dataversion", 1);

END;
