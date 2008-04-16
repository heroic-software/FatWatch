CREATE TABLE weight (
	month INTEGER,
	day INTEGER,
	measuredValue REAL,
	trendValue REAL,
	flag INTEGER,
	note TEXT
);
CREATE UNIQUE INDEX date ON weight (month, day);

-- January 2008
-- INSERT INTO weight VALUES ((1 - 1) + 12*(2008 - 2001), 2, 170.0, 100, 0, "The first day");

-- April 2008
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001), 3, 178.5, 100, 0, "The first day");
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001), 4, 178.0, 100, 1, NULL);
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001), 5, 177.0, 100, 0, NULL);
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001), 6, 177.0, 100, 0, NULL);

INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001), 8, 179.0, 100, 0, NULL);
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001), 9, 180.0, 100, 0, NULL);
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001),10, 180.5, 100, 0, NULL);
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001),11, 180.0, 100, 0, NULL);

INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001),13, 177.0, 100, 0, NULL);
