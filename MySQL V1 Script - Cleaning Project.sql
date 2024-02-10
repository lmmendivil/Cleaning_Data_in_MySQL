SELECT * 
FROM bakery.customer_sweepstakes;

ALTER TABLE customer_sweepstakes RENAME COLUMN `ï»¿sweepstake_id` TO `sweepstake_id`; 



# REMOVING DUPLICATES FROM THE TABLE

-- FINDING DUPLICATES
SELECT customer_id, COUNT(customer_id)
FROM customer_sweepstakes
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;

SELECT sweepstake_id, customer_id, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id)
FROM customer_sweepstakes;

-- DUPLICATED ROWS
WITH duplicatesCTE AS 
(
SELECT sweepstake_id, customer_id, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id) AS repeated_rows
FROM customer_sweepstakes
)
SELECT sweepstake_id
FROM duplicatesCTE
WHERE repeated_rows > 1;


-- DELETING DUPLICATED ROWS
DELETE FROM customer_sweepstakes
WHERE sweepstake_id IN (
						SELECT sweepstake_id
						FROM (
								SELECT sweepstake_id, customer_id, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id) AS repeated_rows
								FROM customer_sweepstakes
							 ) repeated_table
						WHERE repeated_rows > 1      
						);
 
 
 
 # STANDARDIZE COLUMN "phone"
 
SELECT * 
FROM bakery.customer_sweepstakes;
 
SELECT phone
FROM customer_sweepstakes;

-- REMOVING CHARACTERS AND LEAVING ONLY NUMBERS
SELECT phone, REGEXP_REPLACE(phone, "[()-/]", "")
FROM customer_sweepstakes;
 
UPDATE customer_sweepstakes
SET phone = REGEXP_REPLACE(phone, "[()-/]", "");

-- SETTING BLANKS TO NULLS 
UPDATE customer_sweepstakes
SET phone = NULL 
WHERE phone = "";

-- FORMATTING PHONE NUMBERS
SELECT phone, CONCAT(SUBSTRING(phone, 1,3),"-", SUBSTRING(phone, 4,3),"-", SUBSTRING(phone, 7,4))
FROM customer_sweepstakes;
 
UPDATE customer_sweepstakes
SET phone = CONCAT(SUBSTRING(phone, 1,3),"-", SUBSTRING(phone, 4,3),"-", SUBSTRING(phone, 7,4));




# STANDARDIZE COLUMN "birth_date"

SELECT * 
FROM bakery.customer_sweepstakes;

SELECT birth_date 
FROM customer_sweepstakes;

-- CONVERTING FIELD INTO PROPER DATA TYPE
SELECT birth_date, STR_TO_DATE(birth_date, "%m/%d/%Y")
FROM customer_sweepstakes;

SELECT birth_date, CONCAT(SUBSTRING(birth_date, 9,2), "/", SUBSTRING(birth_date, 6,2), "/", SUBSTRING(birth_date, 1,4))
FROM customer_sweepstakes
WHERE STR_TO_DATE(birth_date, "%m/%d/%Y") IS NULL;

SELECT birth_date
FROM customer_sweepstakes
WHERE birth_date REGEXP "^19.+[0-9]"
;

UPDATE customer_sweepstakes
SET birth_date = CONCAT(SUBSTRING(birth_date, 9,2), "/", SUBSTRING(birth_date, 6,2), "/", SUBSTRING(birth_date, 1,4))
WHERE birth_date REGEXP "^19.+[0-9]"
;

UPDATE customer_sweepstakes
SET birth_date = STR_TO_DATE(birth_date, "%m/%d/%Y");



#BREAKING "address" COLUMN DOWN TO SEPARATE COLUMNS

SELECT * 
FROM customer_sweepstakes;

SELECT address, SUBSTRING_INDEX(address, ",", 1) street,
SUBSTRING_INDEX(SUBSTRING_INDEX(address, ",", 2),",", -1) city,
SUBSTRING_INDEX(address, ",", -1) state 
FROM customer_sweepstakes;

-- Creating new fields for each part of the address
ALTER TABLE customer_sweepstakes
ADD COLUMN street VARCHAR(50) AFTER address,
ADD COLUMN city VARCHAR(50) AFTER street,
ADD COLUMN state VARCHAR(50) AFTER city;

-- Populating new columns
UPDATE customer_sweepstakes
SET street = SUBSTRING_INDEX(address, ",", 1), 
city =  SUBSTRING_INDEX(SUBSTRING_INDEX(address, ",", 2),",", -1),
state = SUBSTRING_INDEX(address, ",", -1)
;

SELECT state, TRIM(state), city, TRIM(city)
FROM customer_sweepstakes;

UPDATE customer_sweepstakes
SET city = TRIM(city), state = TRIM(state);

UPDATE customer_sweepstakes
SET state = UPPER(state);


-- Deleting "address" column
ALTER TABLE customer_sweepstakes
DROP COLUMN address;

UPDATE customer_sweepstakes
SET income = NULL
WHERE income = "";



#STANDARDIZE "Are you over 18" COLUMN

SELECT * 
FROM customer_sweepstakes;



SELECT `Are you over 18?`, CASE
WHEN `Are you over 18?` = "Yes" THEN "Y"
WHEN `Are you over 18?` = "No" THEN "N"
ELSE `Are you over 18?`
END
FROM customer_sweepstakes;



UPDATE customer_sweepstakes
SET `Are you over 18?` = 
CASE
WHEN `Are you over 18?` = "Yes" THEN "Y"
WHEN `Are you over 18?` = "No" THEN "N"
ELSE `Are you over 18?`
END;



# A LITTLE ANALYSIS ON COLUMN "Are you over 18?" 
-- Is the answer "Yes"or "No" correct according to the birth_date?

SELECT birth_date,`Are you over 18?`
FROM customer_sweepstakes;

SELECT birth_date,`Are you over 18?`, 
IF (YEAR(birth_date) < (YEAR(NOW()) - 18), "Y", "N")
FROM customer_sweepstakes;

UPDATE customer_sweepstakes
SET `Are you over 18?` = IF (YEAR(birth_date) < (YEAR(NOW()) - 18), "Y", "N");

SELECT *
FROM customer_sweepstakes;

#DELETING USLESS COLUMUNS ("favorite_color")
ALTER TABLE customer_sweepstakes
DROP COLUMN favorite_color;
