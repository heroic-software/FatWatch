BEGIN EXCLUSIVE TRANSACTION;
CREATE INDEX IF NOT EXISTS trendValue_index ON weight (trendValue);
DELETE FROM weight WHERE (measuredValue IS NULL) AND (flag = 0) AND (ifnull(length(note),0) = 0);
INSERT INTO metadata VALUES ('dataversion', 2);
COMMIT TRANSACTION;
