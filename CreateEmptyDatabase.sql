CREATE TABLE weight (
	month INTEGER,
	day INTEGER,
	measuredValue REAL,
	trendValue REAL,
	flag INTEGER,
	note TEXT
);
CREATE UNIQUE INDEX date ON weight (month, day);

# January 2008
INSERT INTO weight VALUES ((1 - 1) + 12*(2008 - 2001), 25, 168.5, 179.2, 1, "Real first day");

# April 2008
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001), 3, 178.5, 179.2, 0, "The first day");
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001), 4, 168.5, 179.2, 1, NULL);
INSERT INTO weight VALUES ((4 - 1) + 12*(2008 - 2001), 5, 158.5, 179.2, 0, NULL);
