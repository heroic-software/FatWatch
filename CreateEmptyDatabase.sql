CREATE TABLE weight (
	date INTEGER PRIMARY KEY,
	measuredValue REAL,
	trendValue REAL,
	flag INTEGER,
	note TEXT
);
INSERT INTO weight VALUES ((51 + 7 * 365) * 86400, 178.5, 179.2, 0, "The first day");
INSERT INTO weight VALUES ((52 + 7 * 365) * 86400, 168.5, 179.2, 1, NULL);
INSERT INTO weight VALUES ((53 + 7 * 365) * 86400, 158.5, 179.2, 0, NULL);
