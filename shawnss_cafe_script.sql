# UNDERSTANDING THE DATA AND WHAT NEEDS TO BE CLEANED

SELECT *
FROM shawnss_cafe_data.sales_data_raw;

SELECT DISTINCT(payment_method)
FROM shawnss_cafe_data.sales_data_raw;
# Payment Methods = Credit Card, Cash, Digital Wallet, UNKNOWN, ERROR, ''


SELECT DISTINCT(item)
FROM shawnss_cafe_data.sales_data_raw;
# Items = Coffee, Cake, Cookie, Salad, Smoothie, Sandwich, Juice, Tea, UKNOWN, ERROR, ''


SELECT item, price_per_unit
FROM shawnss_cafe_data.sales_data_raw
WHERE price_per_unit != 'ERROR' AND price_per_unit != 'UNKNOWN' AND price_per_unit != ''
	AND item != 'ERROR' AND item != 'UNKNOWN' AND item != ''
GROUP BY item, price_per_unit
ORDER BY price_per_unit ASC;
# Cookie = $1          Tea = $1.50             Coffee = $2
# Cake = $3            Juice = $3              Smoothie = $4
# Sandwich = $4        Salad = $5


SELECT DISTINCT(location)
FROM shawnss_cafe_data.sales_data_raw;
# Takeaway, In-Store, UNKNOWN, ERROR, ''


------------------------------------------------------------------------------------------------------------

# STAGING TABLE 1 used to change values to be the same in the following columns: quantity, price_per_unit, total_spent, location, payment_method

CREATE TABLE sales_staging1 AS
SELECT *
FROM shawnss_cafe_data.sales_data_raw;

SELECT COUNT(*) 
FROM shawnss_cafe_data.sales_staging1;


SELECT DISTINCT(quantity)
FROM sales_staging1
ORDER BY quantity ASC;

SELECT DISTINCT(total_spent)
FROM sales_staging1
ORDER BY total_spent ASC;

SELECT DISTINCT(price_per_unit)
FROM sales_staging1
ORDER BY price_per_unit ASC;

# Updating the quantity column to have incomplete data values all say UNKNOWN
UPDATE sales_staging1
SET quantity = 'Unknown'
WHERE quantity = 'ERROR';

UPDATE sales_staging1
SET quantity = 'Unknown'
WHERE quantity = '';

SELECT COUNT(*) 
FROM shawnss_cafe_data.sales_staging1
WHERE quantity = 'Unknown';       # 479 between all 
# Updating the quantity column to have incomplete data values all say UNKNOWN

# # Updating the price_per_unit column to have incomplete data values all say UNKNOWN
UPDATE sales_staging1
SET price_per_unit = 'Unknown'
WHERE price_per_unit = 'ERROR';

UPDATE sales_staging1
SET price_per_unit = 'Unknown'
WHERE price_per_unit = '';

SELECT COUNT(*) 
FROM shawnss_cafe_data.sales_staging1                   
WHERE price_per_unit = 'Unknown' OR price_per_unit = 'ERROR' OR price_per_unit = '';      # 533 between all    
# Updating the price_per_unit column to have incomplete data values all say UNKNOWN

# Updating the total_spent column to have incomplete data values all say UNKNOWN
UPDATE sales_staging1
SET total_spent = 'Unknown'
WHERE total_spent = 'ERROR';

UPDATE sales_staging1
SET total_spent = 'Unknown'
WHERE total_spent = '';

SELECT COUNT(*) 
FROM shawnss_cafe_data.sales_staging1
WHERE total_spent = 'Unknown' OR total_spent = 'ERROR' OR total_spent = '';     # 502 between all
# Updating the total_spent column to have incomplete data values all say UNKNOWN


SELECT COUNT(*)
FROM sales_staging1;

# Updating the payment_method column to have incomplete data values all say UNKNOWN
UPDATE sales_staging1
SET payment_method = 'Unknown'
WHERE payment_method = 'ERROR';

UPDATE sales_staging1
SET payment_method = 'Unknown'
WHERE payment_method = '';

SELECT DISTINCT(payment_method)
FROM sales_staging1;
# Updating the payment_method column to have incomplete data values all say UNKNOWN

# Updating the location column to have incomplete data values all say UNKNOWN
UPDATE sales_staging1
SET location = 'Unknown'
WHERE location = 'ERROR';

UPDATE sales_staging1
SET location = 'Unknown'
WHERE location = '';

SELECT DISTINCT(location)
FROM sales_staging1;
# Updating the payment_method column to have incomplete data values all say UNKNOWN

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE sales_staging3
SET total_spent = NULL
WHERE total_spent = 'UNKNOWN';

UPDATE sales_staging3
SET price_per_unit = NULL                     # Changing these values to NULL, so that I can use Division in the update command later
WHERE price_per_unit = 'UNKNOWN';

UPDATE sales_staging3
SET quantity = NULL
WHERE quantity = 'UNKNOWN';
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# STAGING TABLE 2 created to change transaction_date to DATE data type as well as created columns for Month of the year AND change unknown items to all say UNKNOWN

CREATE TABLE sales_staging2 AS
SELECT *
FROM shawnss_cafe_data.sales_staging1;      # New Table to alter and Impute Data

SELECT *
FROM sales_staging2;       # Checking to make sure that Staging2 has appropriate data

SELECT COUNT(*)
FROM sales_staging2
WHERE transaction_date = NULL;


# Changing Date from STRING to DATE
UPDATE sales_staging2
SET transaction_date = NULL
WHERE transaction_date = 'UNKNOWN';

UPDATE sales_staging2
SET transaction_date = NULL
WHERE transaction_date = 'ERROR';

UPDATE sales_staging2
SET transaction_date = NULL
WHERE transaction_date = '';             # Used these UPDATE queries to make all dates with those values = to NULL then went into Alter Table and used that to convert to DATE
                                         # Had to change values to NULL because an error was happening when it would run into the values 'ERROR', 'UNKNOWN', ''

SELECT MAX(transaction_date), MIN(transaction_date)
FROM sales_staging2;      # Verifying all data is in the year 2023

SELECT *, MONTHNAME(transaction_date) AS transaction_month
FROM sales_staging2;

ALTER TABLE sales_staging2
ADD COLUMN transaction_month varchar(255);

UPDATE sales_staging2
SET transaction_month = MONTHNAME(transaction_date);

UPDATE sales_staging2
SET item = 'UNKNOWN'
WHERE item = 'ERROR';

UPDATE sales_staging2
SET item = 'UNKNOWN'
WHERE item = '';

SELECT *
FROM sales_staging2;


# STAGING TABLE 3 Created to impute data into the columns: item, quantity, price_per_unit, total_spent

CREATE TABLE sales_staging3 AS
SELECT *
FROM shawnss_cafe_data.sales_staging2; 

SELECT *
FROM sales_staging3;

SELECT COUNT(*)
FROM sales_staging3;


# Updating item column to display correct item

SELECT *
FROM sales_staging3
WHERE quantity IS NULL OR price_per_unit IS NULL OR total_spent IS NULL;

UPDATE sales_staging3
SET item = 'Cookie'
WHERE item = 'UNKNOWN' AND price_per_unit = 1;

UPDATE sales_staging3
SET item = 'Tea'
WHERE item = 'UNKNOWN' AND price_per_unit = 1.5;

UPDATE sales_staging3
SET item = 'Coffee'
WHERE item = 'UNKNOWN' AND price_per_unit = 2;

UPDATE sales_staging3
SET item = 'Cake or Juice'
WHERE item = 'UNKNOWN' AND price_per_unit = 3;

UPDATE sales_staging3
SET item = 'Smoothie or Sandwich'
WHERE item = 'UNKNOWN' AND price_per_unit = 4;



# Cookie = $1          Tea = $1.50             Coffee = $2
# Cake = $3            Juice = $3              Smoothie = $4
# Sandwich = $4        Salad = $5


# Updating columns dealing with cookie
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Cookie' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Cookie' AND quantity IS NULL;

SELECT COUNT(*)
FROM sales_staging3
WHERE item = 'Cookie' AND price_per_unit IS NULL;

UPDATE sales_staging3
SET price_per_unit = 1
WHERE item = 'Cookie' AND price_per_unit IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Cookie'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Cookie'
	AND total_spent IS NULL;
    

# Updating Tea
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Tea' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Tea' AND quantity IS NULL;

SELECT COUNT(*)
FROM sales_staging3
WHERE item = 'Tea' AND price_per_unit IS NULL;

UPDATE sales_staging3
SET price_per_unit = 1.5
WHERE item = 'Tea' AND price_per_unit IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Tea'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Tea'
	AND total_spent IS NULL;
    

# Updating Coffee
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Coffee' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Coffee' AND quantity IS NULL;

SELECT COUNT(*)
FROM sales_staging3
WHERE item = 'Coffee' AND price_per_unit IS NULL;

UPDATE sales_staging3
SET price_per_unit = 2
WHERE item = 'Coffee' AND price_per_unit IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Coffee'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Coffee'
	AND total_spent IS NULL;

	
# Updating Salad
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Salad' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Salad' AND quantity IS NULL;

SELECT COUNT(*)
FROM sales_staging3
WHERE item = 'Salad' AND price_per_unit IS NULL;

UPDATE sales_staging3
SET price_per_unit = 5
WHERE item = 'Salad' AND price_per_unit IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Salad'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Salad'
	AND total_spent IS NULL;
    
    
# Updating Cake
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Cake' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Cake' AND quantity IS NULL;

SELECT COUNT(*)
FROM sales_staging3
WHERE item = 'Cake' AND price_per_unit IS NULL;

UPDATE sales_staging3
SET price_per_unit = 3
WHERE item = 'Cake' AND price_per_unit IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Cake'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Cake'
	AND total_spent IS NULL;


# Updating Juice
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Juice' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Juice' AND quantity IS NULL;

SELECT COUNT(*)
FROM sales_staging3
WHERE item = 'Juice' AND price_per_unit IS NULL;

UPDATE sales_staging3
SET price_per_unit = 3
WHERE item = 'Juice' AND price_per_unit IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Juice'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Juice'
	AND total_spent IS NULL;


# Updating Smoothie
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Smoothie' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Smoothie' AND quantity IS NULL;

SELECT COUNT(*)
FROM sales_staging3
WHERE item = 'Smoothie' AND price_per_unit IS NULL;

UPDATE sales_staging3
SET price_per_unit = 4
WHERE item = 'Smoothie' AND price_per_unit IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Smoothie'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Smoothie'
	AND total_spent IS NULL;


# Updating Sandwich
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Sandwich' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Sandwich' AND quantity IS NULL;

SELECT COUNT(*)
FROM sales_staging3
WHERE item = 'Sandwich' AND price_per_unit IS NULL;

UPDATE sales_staging3
SET price_per_unit = 4
WHERE item = 'Sandwich' AND price_per_unit IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Sandwich'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Sandwich'
	AND total_spent IS NULL;



# Updating 'Smoothie or Sandwich'
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Smoothie or Sandwich' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Smoothie or Sandwich' AND quantity IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Smoothie or Sandwich'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Smoothie or Sandwich'
	AND total_spent IS NULL;



# Updating 'Cake or Juice'
SELECT *, total_spent/price_per_unit AS new_quantity
FROM sales_staging3
WHERE item = 'Cake or Juice' AND quantity IS NULL;

UPDATE sales_staging3
SET quantity = total_spent/price_per_unit
WHERE item = 'Cake or Juice' AND quantity IS NULL;

SELECT *, quantity * price_per_unit AS new_total
FROM sales_staging3
WHERE item = 'Cake or Juice'
	AND total_spent IS NULL;
    
UPDATE sales_staging3
SET total_spent = quantity * price_per_unit
WHERE item = 'Cake or Juice'
	AND total_spent IS NULL;


SELECT *
FROM sales_staging3
WHERE quantity IS NULL OR price_per_unit IS NULL OR total_spent IS NULL;

UPDATE sales_staging3
SET price_per_unit = total_spent/quantity
WHERE item = 'UNKNOWN' AND price_per_unit IS NULL;

UPDATE sales_staging3
SET quantity = 5, price_per_unit = 5, item = 'Salad'
WHERE transaction_id = 'TXN_7376255';

UPDATE sales_staging3
SET item = 'Unknown'
WHERE item = 'UNKNOWN';

SELECT *
FROM sales_staging3
WHERE item = 'Unknown';

UPDATE sales_staging3
SET item = 'Salad'
WHERE item = 'Unknown' AND price_per_unit = 5;
    
    

