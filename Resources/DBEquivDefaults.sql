BEGIN;

DELETE FROM equivalents;

-- Activities
-- http://riskfactor.cancer.gov/tools/atus-met/met.php
INSERT INTO equivalents VALUES (NULL, 0,0, "Sitting Around",NULL,1);
INSERT INTO equivalents VALUES (NULL, 0,0, "Bowling",NULL,3.0);
INSERT INTO equivalents VALUES (NULL, 0,0, "Walking",NULL,3.8);
INSERT INTO equivalents VALUES (NULL, 0,0, "Dancing",NULL,4.5);
INSERT INTO equivalents VALUES (NULL, 0,0, "Hiking",NULL,6.0);
INSERT INTO equivalents VALUES (NULL, 0,0, "Rodeo Participation",NULL,6.0);
INSERT INTO equivalents VALUES (NULL, 0,0, "Running",NULL,7.5);

-- Foods
INSERT INTO equivalents VALUES (NULL, 1,0, "protein","g",4);
INSERT INTO equivalents VALUES (NULL, 1,1, "carbohydrate","g",4);
INSERT INTO equivalents VALUES (NULL, 1,2, "fat","g",9);
INSERT INTO equivalents VALUES (NULL, 1,3, "alcohol","g",7);
INSERT INTO equivalents VALUES (NULL, 1,4, "apple (medium)","count",71.8);
INSERT INTO equivalents VALUES (NULL, 1,5, "cola","oz",100/8);
INSERT INTO equivalents VALUES (NULL, 1,6, "cola (12 oz)","can",12*100/8);
INSERT INTO equivalents VALUES (NULL, 1,7, "cola (20 oz)","bottle",20*100/8);
INSERT INTO equivalents VALUES (NULL, 1,8, "beer, regular (12 oz)","can",153.1);
INSERT INTO equivalents VALUES (NULL, 1,9, "beer, light (12 oz)","can",102.7);

END;
