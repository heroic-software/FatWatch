BEGIN;

DELETE FROM equivalents;

-- Activities
-- http://riskfactor.cancer.gov/tools/atus-met/met.php

INSERT INTO equivalents VALUES (NULL, 0,2, "walking",NULL,3.8);
INSERT INTO equivalents VALUES (NULL, 0,3, "dancing",NULL,4.5);
INSERT INTO equivalents VALUES (NULL, 0,4, "hiking",NULL,6.0);
INSERT INTO equivalents VALUES (NULL, 0,5, "running",NULL,7.5);

-- Foods
-- http://calorielab.com/index.html
-- http://www.fourmilab.ch/hackdiet/e4/foodcalories.html

INSERT INTO equivalents VALUES (NULL, 1, 0, "cola (12 oz)","can",150);
INSERT INTO equivalents VALUES (NULL, 1, 1, "cola (20 oz)","bottle",250);
INSERT INTO equivalents VALUES (NULL, 1, 2, "beer (12 oz)","can",145);
INSERT INTO equivalents VALUES (NULL, 1, 3, "beer, light (12 oz)","can",100);
INSERT INTO equivalents VALUES (NULL, 1, 4, "chocolate","kisses",24);
INSERT INTO equivalents VALUES (NULL, 1, 5, "egg","large",82);
INSERT INTO equivalents VALUES (NULL, 1, 6, "egg white","large",17);
INSERT INTO equivalents VALUES (NULL, 1, 7, "bacon","slice",36);
INSERT INTO equivalents VALUES (NULL, 1, 8, "apple","medium",80);
INSERT INTO equivalents VALUES (NULL, 1, 9, "banana","medium",101);
INSERT INTO equivalents VALUES (NULL, 1,10, "orange","medium",71);
INSERT INTO equivalents VALUES (NULL, 1,11, "blue cheese dressing","tbsp",80);
INSERT INTO equivalents VALUES (NULL, 1,12, "Italian dressing","tbsp",70);
INSERT INTO equivalents VALUES (NULL, 1,13, "white bread","slice",68);
INSERT INTO equivalents VALUES (NULL, 1,14, "wheat bread","slice",67);
INSERT INTO equivalents VALUES (NULL, 1,15, "peanut butter","tbsp",94);
INSERT INTO equivalents VALUES (NULL, 1,16, "jelly","tbsp",49);
INSERT INTO equivalents VALUES (NULL, 1,17, "tuna","can",100);
INSERT INTO equivalents VALUES (NULL, 1,18, "mayonnaise","tbsp",100);
INSERT INTO equivalents VALUES (NULL, 1,19, "yellow mustard","tbsp",10);
INSERT INTO equivalents VALUES (NULL, 1,20, "salt","tbsp",0);

INSERT INTO equivalents VALUES (NULL, 1,96, "protein","g",4);
INSERT INTO equivalents VALUES (NULL, 1,97, "carbohydrate","g",4);
INSERT INTO equivalents VALUES (NULL, 1,98, "fat","g",9);
INSERT INTO equivalents VALUES (NULL, 1,99, "alcohol","g",7);

END;
