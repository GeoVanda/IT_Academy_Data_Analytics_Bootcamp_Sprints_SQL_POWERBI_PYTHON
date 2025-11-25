-- SPRINT 4
-- Nivel 1 ---------------------------------------------------------------------------------------------------------

/* Descarga los archivos CSV, estudiales y diseña una base de datos con un esquema de estrella que contenga, 
al menos 4 tablas de las que puedas realizar las siguientes consultas:

- Ejercicio 1
Realiza una subconsulta que muestre a todos los usuarios con más de 30 transacciones utilizando al menos 2 tablas. */

-- Ejercicio 2
-- Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.

------------------------------------------------------------------------------------------------------------------------------
-- 1. CREAR BBDD

CREATE DATABASE SPRINT4;

-- 2. CREAR TABLAS

CREATE TABLE companies(
	company_id VARCHAR(20), 
    company_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(100) UNIQUE,
	country VARCHAR(50), 
    website VARCHAR(150),
	PRIMARY KEY (company_id)
);

CREATE TABLE credit_cards (
    id VARCHAR(20),
    user_id INT NOT NULL, 
    iban VARCHAR(34) NOT NULL UNIQUE, -- IBAN, formato estándar con longitud máxima de 34 caracteres
    pan VARCHAR(30) NOT NULL UNIQUE, -- Número de tarjeta, longitud fija de 16 caracteres - pero hay datos con espacios - mas largos en el csv
    pin CHAR(4) NOT NULL, -- PIN credit_cards de 4 dígitos 
    cvv CHAR(3) NOT NULL, -- CVV de 3 dígitos 
    track1 VARCHAR(80) NOT NULL, 
    track2 VARCHAR(40) NOT NULL, 
    expiring_date  VARCHAR(10),      -- ver luego de la carga de transformar en DATE en formato YYYY-MM-DD 
	PRIMARY KEY (id), 
    CONSTRAINT chk_pin CHECK (LENGTH(pin) = 4), -- Restricción para asegurar que el PIN tenga 4 caracteres
    CONSTRAINT chk_cvv CHECK (LENGTH(cvv) = 3) -- Restricción para asegurar que el CVV tenga 3 caracteres
);

CREATE TABLE products (
    id INT,
    product_name VARCHAR(255), 
    price VARCHAR(20),  -- tiene simbolo $ en el archivo a cargar - se puede modificar luego
    colour CHAR(7) CHECK (colour REGEXP '^#[0-9a-fA-F]{6}$'),  -- restricción CHECK que valida que el campo colour contenga un código de color hexadecimal correcto.
    weight INT CHECK (weight > 0), -- Peso en unidades enteras, debe ser positivo
    warehouse_id VARCHAR(10), 
    PRIMARY KEY (id)
    );
 
CREATE TABLE transactions (
    id CHAR(36), 
    card_id VARCHAR(20) NOT NULL, 
    business_id VARCHAR(20) NOT NULL, 
    timestamp DATETIME, 
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0), -- Monto de la transacción, debe ser positivo
    declined BOOLEAN NOT NULL, 
    product_ids VARCHAR(255), 
    user_id INT NOT NULL, 
    lat DECIMAL(10,7) CHECK (lat BETWEEN -90 AND 90), 
    longitude DECIMAL(10,7) CHECK (longitude BETWEEN -180 AND 180), 
    PRIMARY KEY (id)
    );
    
-- CREAR UNA TABLA UNIFICADA A PARTIR DE LAS 3 TABLAS DE USERS DE CANADA, UK Y US YA QUE TODAS TIENEN MISMOS CAMPOS Y ESTRUCTURA

CREATE TABLE users (
    id INT, 
    name VARCHAR(100), 
    surname VARCHAR(100), 
    phone VARCHAR(30), 
    email VARCHAR(150) UNIQUE, 
    birth_date VARCHAR(20), -- transformar después de la carga a formato date
    country VARCHAR(100), 
    city VARCHAR(100), 
    postal_code VARCHAR(20), 
    address VARCHAR(255), 
    PRIMARY KEY (id)
);
-- CARGAR LOS CSV E INSERTARLOS EN LAS TABLAS RESPECTIVAS

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS  
(company_id,company_name,phone,email,country,website);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv"
INTO TABLE credit_cards 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date) -- revisar esto -- resetear en con alter table el tipo de dato date**
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');  -- en la CARGA SE TRANSFORMA el tipo de dato de expiring_date a DATE mm/dd/yy

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv"
INTO TABLE products 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,product_name,price,colour,weight,warehouse_id);

-- Transformaciones en la tablas/columnas

-- Quitar el signo $ de price

UPDATE products
SET price = REPLACE(price, '$', ''); 

-- Modificar en la TABLA el tipo de dato de esta columna 
ALTER TABLE products MODIFY price DECIMAL(10,2);

-- Tabla transactions

-- Aparece un Warning de datos truncados en las cols lat y longitud
-- Modificar en la tabla creada ambas cols para que coincidan con el .csv

ALTER TABLE transactions MODIFY lat DECIMAL(14,10);  -- DECIMAL(14,10) es un formato común para representar las coordenadas de latitud y longitud en bases de datos
ALTER TABLE transactions MODIFY longitude DECIMAL(14,10);

-- Borrar todos los datos y volver a cargar

TRUNCATE TABLE transactions; 

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,card_id,business_id,timestamp,amount,declined,product_ids,user_id,lat,longitude);

-- Tabla users

-- Los 3 archivos de usuarios .csv tienen la misma estructura, por lo tanto se pueden ir cargando una a una a la tabla users.
-- NO repiten los id.

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_usa.csv"
INTO TABLE users 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id,name,surname,phone,email,birth_date,country,city,postal_code,address);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_uk.csv"
INTO TABLE users 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id,name,surname,phone,email,birth_date,country,city,postal_code,address);

-- al repetirse un mail de este archivo que ya está en la carga desde el archivo anterior, se genera el error code 1062.
-- Tomo la opcion de eliminar de la tabla users la restriccion impuesta inicialmente de UNIQUE en el campo email

ALTER TABLE users DROP INDEX  email;

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_uk.csv"
INTO TABLE users 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id,name,surname,phone,email,birth_date,country,city,postal_code,address);

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_ca.csv"
INTO TABLE users 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id,name,surname,phone,email,birth_date,country,city,postal_code,address);

-- Chequeo la tabla completa- Son 275 registros total
SELECT * FROM users;

-- Agregar las relaciones entre tablas

ALTER TABLE transactions
ADD FOREIGN KEY (business_id) REFERENCES companies (company_id),
ADD FOREIGN KEY (card_id) REFERENCES credit_cards (id),
ADD FOREIGN KEY (user_id) REFERENCES users (id);

-- Ejercicio 1

-- Realiza una subconsulta que muestre a todos los usuarios con más de 30 transacciones utilizando al menos 2 tablas.

SELECT u.id, u.name, u.surname                             
FROM users u
WHERE u.id IN (SELECT t.user_id 
			FROM transactions t
            GROUP BY t.user_id
            HAVING COUNT(t.id) > 30)
ORDER BY u.id;
            
-- Ejercicio 2
-- Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.

-- Buscar el nombre correcto de la compañia
SELECT * FROM companies WHERE company_name LIKE '%Donec%';  

SELECT cc.iban, ROUND(AVG(t.amount),2)
FROM transactions t INNER JOIN companies c ON  t.business_id = c.company_id
INNER JOIN credit_cards cc ON t.card_id = cc.id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

-- Nivel 2 --------------------------------------------------------------------------------------------------------------------------
/* Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas tres transacciones
 fueron declinadas y genera la siguiente consulta:

Ejercicio 1
¿Cuántas tarjetas están activas? */   

-- Ordenar una query con funcion ventana ROW_NUMBER() PARTICIONADA POR IBAN Y ORDENADA POR TIMESTAMP DESC (primero las ultimas)
-- Filtrar por hasta 3 ROWS de cada particion por IBAN
-- Clasificar las ultimas 3 transacciones por IBAN en Activas o Inactivas segun esas ultimas 3 por tarjeta hayan sido todas rechazadas (suma= 3) o no.
-- Contar cuantas clasifican como Activas

SELECT COUNT(*)  AS Cantidad_Activas 
FROM( SELECT s3.iban, SUM(s3.estado) AS total_declined,
       CASE WHEN SUM(s3.estado) = 3 THEN 'inactiva' ELSE 'activa' END AS clasification
FROM ( SELECT * 
FROM ( SELECT ROW_NUMBER() OVER (PARTITION BY cc.iban ORDER BY s1.fecha DESC) AS row_n, s1.iban, s1.estado
FROM ( SELECT cc.iban AS iban, t.declined AS estado, t.timestamp AS fecha
	   FROM transactions t
	   JOIN credit_cards cc ON cc.id = t.card_id
	   ORDER BY cc.iban, t.timestamp DESC ) AS s1) s2
WHERE s2.row_n <= 3) s3
GROUP BY s3.iban) s4
WHERE clasification = 'activa';

-- Bajo este criterio de clasificación todas las tarjetas estan activas

-- Crear Tabla nueva

CREATE TABLE credit_card_status (
    iban VARCHAR(34) PRIMARY KEY,  
    classification ENUM('activa', 'inactiva'));
    
-- Insertar los datos de la query 

INSERT INTO credit_card_status (iban, classification)
SELECT s3.iban,        CASE WHEN SUM(s3.estado) = 3 THEN 'inactiva' ELSE 'activa' END AS classification
FROM ( SELECT * 
FROM ( SELECT ROW_NUMBER() OVER (PARTITION BY cc.iban ORDER BY s1.fecha DESC) AS row_n, s1.iban, s1.estado
FROM ( SELECT cc.iban AS iban, t.declined AS estado, t.timestamp AS fecha
	   FROM transactions t
	   JOIN credit_cards cc ON cc.id = t.card_id
	   ORDER BY cc.iban, t.timestamp DESC ) AS s1) s2
WHERE s2.row_n <= 3) s3
GROUP BY s3.iban;
   
-- Chequeo tabla -- **************************
select * from credit_card_status;

-- Nivel 3 ------------------------------------------------------------------------------

/* Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, 
teniendo en cuenta que desde transaction tienes product_ids.*/

-- Ejercicio 1
-- Necesitamos conocer el número de veces que se ha vendido cada producto.

-- Chequear situacion inicial col product_ids -tabla transactions

SELECT id, product_ids 
FROM transactions;

-- Transformar la columna product_ids
-- Crear una tabla puente o intermedia: transactions-products para poder unir por su intermedio 
-- las tablas originales transactions y products.

-- Chequear de tipos de datos de col product_ids para reconvertir
SHOW COLUMNS FROM transactions WHERE Field = 'product_ids';  -- es varchar(255)

-- Acomodar correctamente la cadena separada por comas
 UPDATE transactions SET product_ids = TRIM(product_ids);
 
-- Extraer valores de cada product_ids de la tabla transactions y transformarlo en filas cada una con un solo id de producto

SELECT id AS transaction_id, SUBSTRING_INDEX(product_ids, ',', 1) AS product_id 
FROM transactions WHERE product_ids IS NOT NULL
UNION ALL
SELECT id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1) AS product_id 
FROM transactions WHERE product_ids LIKE '%,%'
UNION ALL
SELECT id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1) AS product_id 
FROM transactions WHERE product_ids LIKE '%,%,%'
UNION ALL
SELECT id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1) AS product_id 
FROM transactions WHERE product_ids LIKE '%,%,%,%';

 -- Crear la tabla puente transaction_products
	
    CREATE TABLE transaction_products  (
    transaction_id CHAR(36) NOT NULL,
    product_id INT NOT NULL,
	FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
	PRIMARY KEY (transaction_id, product_id)) ;             -- Evita duplicados

-- extraer y cargar csv

SELECT transaction_id, product_id 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transaction_products_1.csv' 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
FROM ( SELECT id AS transaction_id, SUBSTRING_INDEX(product_ids, ',', 1) AS product_id 
FROM transactions WHERE product_ids IS NOT NULL
UNION ALL
SELECT id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1) AS product_id 
FROM transactions WHERE product_ids LIKE '%,%'
UNION ALL
SELECT id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1) AS product_id 
FROM transactions WHERE product_ids LIKE '%,%,%'
UNION ALL
SELECT id, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1) AS product_id 
FROM transactions WHERE product_ids LIKE '%,%,%,%'
) AS transct_prod;

 -- Cargar a la tabla transaction_products desde el archivo .csv guardado- sin INSERT INTO. 

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transaction_products_1.csv' 
INTO TABLE transaction_products 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
(transaction_id, product_id);

-- Chequear la carga
select * from transaction_products;

-- Ejercicio 1
-- Necesitamos conocer el número de veces que se ha vendido cada producto.

SELECT tp.product_id, p.product_name , COUNT(*) AS cant_ventas_producto
FROM transaction_products tp
JOIN products p ON tp.product_id = p.id
JOIN transactions t ON t.id = tp.transaction_id
WHERE declined = 0
GROUP BY tp.product_id, p.product_name
ORDER BY cant_ventas_producto DESC;

-- se venden 26 productos de un total de 100-
