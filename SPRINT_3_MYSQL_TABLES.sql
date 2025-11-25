-- SPRINT 3 -- Tarea S3.01. Manipulación de tablas

-- Nivel 1 -----------------------------------------------------------------------------------------------------

-- Ejercicio 1 

/* Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. 
 La nueva tabla debe ser capaz de identificar de forma única cada tarjeta 
 y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). 
 Después de crear la tabla será necesario que ingreses la información del documento denominado "datos_introducir_credit". 
 Recuerda mostrar el DIAGRAMA y realizar una breve DESCRIPCION del mismo.*/ -- adjunto en PDF --

use transactions;

CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(100) PRIMARY KEY,     
        iban VARCHAR(100),
        pan VARCHAR(100), 
        pin VARCHAR(100),
        cvv VARCHAR(100),
        expiring_date VARCHAR(100));   

select * from credit_card; -- 275 rows

/* Relaciones tablas: transaction - credit_card
Agrego en la Tabla transaction la FK credit_card_id que relaciona con el campo id de la tabla credit_card
generando una relacion uno a  muchos - 1:N - de credit_card a transaction. */

ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Ejercicio 2
-- El departamento de Recursos Humanos ha identificado un error en el número de cuenta del usuario con ID CcU-2938. 
-- La información que debe mostrarse para este registro es: R323456312213576817699999. Recuerda mostrar que el cambio se realizó.

-- Chequeo la existencia del número de cuenta del usuario conID CcU-2938

SELECT * FROM credit_card
WHERE id = 'CcU-2938';

-- Actualizo el cambio

UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

-- Rechequeo que se haya realizado el cambio

SELECT * FROM credit_card
WHERE id = 'CcU-2938';

-- Ejercicio 3
-- En la tabla "transaction" ingresa un nuevo usuario con la siguiente información:

/* Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lato	829.999
longitud	-117.999
amunt	111.11
declined	0  */

-- 1. Chequear si existe y sino insertar en credit_card el id 'CcU-9999'

SELECT * 
FROM credit_card
WHERE id = 'CcU-9999';

INSERT INTO credit_card(id)
VALUES ('CcU-9999');

-- Rechequeo la insercion. OK.

-- 2. Chequear si existe y sino insertar en company el id 'b-9999'

SELECT * 
FROM company
WHERE id = 'b-9999';

INSERT INTO company (id) -- -- y rechequeo la insercion. OK.
VALUES ('b-9999');

-- 3- insert :

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)  
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999','b-9999', '9999', '829.999' , '-117.999' , '111.11' , '0' );

-- 4. CHEQUEO LA INSERCION
SELECT * FROM transaction WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- Ejercicio 4 

-- Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. 
-- Recuerda mostrar el cambio realizado.
-- 
-- 1.Verifico que esta el campo 'pan' en la Tabla credit_card original

DESCRIBE credit_card;

-- 2. Elimino campo 'pan' y chequeo su ejecucion con DESCRIBE credit_card

ALTER TABLE credit_card
DROP COLUMN pan; 

-- Nivel 2 ------------------------------------------------------------------------------------------------------

-- Ejercicio 1 
-- Elimina de la tabla transacción el registro con ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de datos.

SELECT * FROM transaction WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

DELETE FROM transaction 
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';  

-- rechequeo el borrado del registro

SELECT * FROM transaction WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Ejercicio 2

/* La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
Se ha solicitado crear una VISTA que proporcione detalles clave sobre las compañías y sus transacciones. 
Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información: 

Nombre de la compañía. Teléfono de contacto. País de residencia. Media de compra realizado por cada compañía. 
Presenta la vista creada, ordenando los datos de mayor a menor por promedio de compra.*/

CREATE VIEW VistaMarketing AS
SELECT c.company_name, c.phone, c.country, round(avg(t.amount),2) AS averige_buy_amount
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE declined = 0                               -- transacciones aceptadas
GROUP BY c.company_name, c.phone, c.country
ORDER BY averige_buy_amount DESC
;

SELECT * FROM VistaMarketing;

-- Ejercicio 3
-- Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"

SELECT * FROM VistaMarketing
WHERE country = 'Germany';


-- Nivel 3 -------------------------------------------------------------------------------------------

-- Ejercicio 1
/* La próxima semana tendrás una nueva reunión con los gerentes de marketing. 
Un compañero de tu equipo realizó modificaciones en la base de datos, pero no recuerda cómo las realizó. 
Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama: */
-- Paso a Paso:

-- 1. Creamos la tabla user (incluida en los recursos del ejercicio original en moodle)
-- 2. Inserto los datos (incluida en los recursos del ejercicio original en moodle)
-- 3. Chequeo la tabla

describe user;
select * from user;

-- 4. La relacion User-transaction esta invertida (1 transaccion - muchos usuarios = t.user_id - u.id ===> debe ser: u.id - t.user_id -- 1:N-- 
-- Corregir: 
-- DROP FK en user. Buscar el nombre de la restricción

SHOW CREATE TABLE user;
-- 'user', 'CREATE TABLE `user` (\n  `id` int NOT NULL,\n  `name` varchar(100) DEFAULT NULL,\n  `surname` varchar(100) DEFAULT NULL,\n  `phone` varchar(150) DEFAULT NULL,\n  `email` varchar(150) DEFAULT NULL,\n  `birth_date` varchar(100) DEFAULT NULL,\n  `country` varchar(150) DEFAULT NULL,\n  `city` varchar(150) DEFAULT NULL,\n  `postal_code` varchar(100) DEFAULT NULL,\n  `address` varchar(255) DEFAULT NULL,\n  PRIMARY KEY (`id`),\n  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`id`) REFERENCES `transaction` (`user_id`)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci'

ALTER TABLE user
DROP FOREIGN KEY user_ibfk_1;  

-- 5. Chequeo si se dio de baja la FK en user

SHOW CREATE TABLE user;

CREATE TABLE `user` (
  `id` int NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `surname` varchar(100) DEFAULT NULL,
  `phone` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `birth_date` varchar(100) DEFAULT NULL,
  `country` varchar(150) DEFAULT NULL,
  `city` varchar(150) DEFAULT NULL,
  `postal_code` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. CREAR USER_ID COMO FK EN TRANSACTION 
-- Modifico la tabla transaction para poner a user_id como FK en relacion con id de la tabla user

ALTER TABLE transaction 
ADD FOREIGN KEY (user_id) REFERENCES user(id);

 -- Resultado: Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails. No permite hacer el cambio anterior.

-- .6 Chequeo si hay algun user_id en la tabla transaction que no exista en la tabla 'PARENT' user(id):

SELECT DISTINCT user_id 
FROM transaction 
WHERE user_id NOT IN (SELECT id FROM user);

-- user_id 9999 está en la tabla transaction ('CHILD') pero no existe en la tabla user ('PARENT'). Lo agrego a la tabla user. 

INSERT INTO user (id)
VALUES ('9999');

-- Vuelvo a ejecutar la modificacion:

ALTER TABLE transaction 
ADD FOREIGN KEY (user_id) REFERENCES user(id);

-- 7. Chequeo el esquema de la tabla transaction

SHOW CREATE TABLE transaction;

CREATE TABLE `transaction` (
  `id` varchar(255) NOT NULL,
  `credit_card_id` varchar(15) DEFAULT NULL,
  `company_id` varchar(20) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `declined` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  KEY `credit_card_id` (`credit_card_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `company` (`id`),
  CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`credit_card_id`) REFERENCES `credit_card` (`id`),
  CONSTRAINT `transaction_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `transaction_ibfk_4` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- corregido!

-- 8. Chequear y modificar las tablas/campos de acuerdo con el esquema presentado en el ejercicio.
-- Tabla company

ALTER TABLE company 
DROP website;

-- Tabla credit_card
select * from credit_card;

ALTER TABLE credit_card 
MODIFY COLUMN id VARCHAR(20);

-- Error Code: 1833. Cannot change column 'id': used in a foreign key constraint 'transaction_ibfk_2' of table 'transactions.transaction'--	
-- Chequeo la tabla transaction para buscar el nombre de la restriccion que no me permite modificar credit_card_id.id

SHOW CREATE TABLE transaction;

ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_2;

ALTER TABLE credit_card 
MODIFY COLUMN id VARCHAR(20);

-- AHora sí se pudo modificar credit_card.id

-- Restituyo el FK en la tabla transaction con el mismo nombre de CONSTRAINT

ALTER TABLE transaction 
ADD CONSTRAINT transaction_ibfk_2 
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Chequeo que haya quedado correctamente como en el estado anterior de contraints para 
-- mantener la integridad del modelo

SHOW CREATE TABLE transaction;

---

ALTER TABLE credit_card MODIFY COLUMN iban VARCHAR(50);
ALTER TABLE credit_card MODIFY COLUMN pin VARCHAR (4);
ALTER TABLE credit_card MODIFY COLUMN cvv INT;
ALTER TABLE credit_card MODIFY COLUMN expiring_date VARCHAR(20);
ALTER TABLE credit_card ADD COLUMN fecha_actual DATE;

-- Tabla user

ALTER TABLE user RENAME data_user;
ALTER TABLE user CHANGE email personal_email VARCHAR (150);

-- Tabla transaction - -- SIN CAMBIOS


-- Ejercicio 2
-- La empresa también te solicita crear una VISTA llamada "InformeTecnico" que contenga la siguiente información:
-- Asegúrate de incluir información relevante de ambas tablas y utiliza ALIAS para cambiar de nombre COLUMNAS según sea necesario.
-- Muestra los resultados de la VISTA, ORDENA los resultados de forma DESCendente en función de la variable ID de transacción.

CREATE VIEW InformeTecnico AS
SELECT t.id AS Transaction_ID , u.name AS User_Name , u.surname AS User_Surname, cc.iban AS IBAN, c.company_name AS Company
FROM transaction t 
JOIN data_user u ON  t.user_id = u.id
JOIN credit_card cc ON t.credit_card_id = cc.id
JOIN company c ON t.company_id = c.id;

SELECT * FROM InformeTecnico
ORDER BY Transaction_ID DESC;


