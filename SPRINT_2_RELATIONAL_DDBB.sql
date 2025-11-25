USE transactions;

-- Nivel 1 ------------------------------------------------------------------
-- Ejercicio 1

 /* A partir de los documentos adjuntos (estructura_datos y datos_introducir), 
 importa las dos tablas. Muestra las principales características del esquema creado y 
 explica las diferentes tablas y variables que existen. Asegúrate de incluir un diagrama 
 que ilustre la relación entre las distintas tablas y variables.*/
-- VER PDF ADJUNTO

-- Ejercicio 2

-- Utilizando JOIN realizarás las siguientes consultas:

-- 1. Listado de los países que están realizando compras.

SELECT DISTINCT c.country 
FROM company c
JOIN transaction t
ON c.id = t.company_id;

-- 2. Desde cuántos países se realizan las compras.

SELECT COUNT(DISTINCT c.country) AS Cantidad_Paises
FROM company c
JOIN transaction t
ON c.id = t.company_id;





-- 3. Identifica a la compañía con la mayor media de ventas.

SELECT c.company_name AS Empresas
FROM company c
INNER JOIN transaction t ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY AVG(t.amount) DESC
LIMIT 1;



-- Ejercicio 3
-- Utilizando sólo subconsultas (sin utilizar JOIN):
-- Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT t.*
FROM transaction t
WHERE t.company_id IN (
					SELECT c.id 
                    FROM company c
                    WHERE c.country = 'Germany');


-- Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT c.company_name
FROM company c
WHERE c.id IN (SELECT t.company_id 
				FROM transaction t
                WHERE t.amount > (SELECT avg(t.amount) FROM transaction t));
                

                
-- Eliminar del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.
 
-- no hay empresas en la tabla company que carezcan de transacciones registradas
-- resultado NULL
-- Eliminarlas del sistema (si las hubiera)
 
 DELETE FROM company c	
 WHERE c.id NOT IN (	
				SELECT t.company_id
                FROM transaction t);

-- Nivel 2 ---------------------------------------------------------------------------

-- Ejercicio 1
-- Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. 
-- Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT date(t.timestamp) fecha, SUM(t.amount) monto_ventas
FROM transaction t
GROUP BY date(t.timestamp)
ORDER BY SUM(t.amount) DESC 
LIMIT 5;

-- Ejercicio 2
-- ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor media.

SELECT c.country, AVG(t.amount)
FROM company c
JOIN  transaction t ON c.id = t.company_id
GROUP BY c.country
ORDER BY AVG(t.amount) DESC;

-- Ejercicio 3
/* En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”.
Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.*/
-- Muestra el listado aplicando JOIN y subconsultas.

SELECT t.*
FROM transaction t JOIN company c ON c.id = t.company_id
WHERE c.country IN (
				SELECT c.country
				FROM company c
				WHERE c.company_name = 'Non Institute') AND c.company_name != 'Non Institute'
ORDER BY t.amount;


-- Muestra el listado aplicando solo subconsultas.

SELECT t.*
FROM transaction t
WHERE t.company_id IN (
					SELECT id
                    FROM company c
                    WHERE c.company_name != 'Non Institute' AND c.country IN (SELECT country
									 FROM company
									 WHERE company_name =  'Non Institute'))
ORDER BY t.amount DESC;
 
-- Nivel 3 ----------------------------------------------------------------------------------------------------------
-- Ejercicio 1

/* Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones
 con un valor comprendido entre 100 y 200 euros y en alguna de estas fechas: 29 de abril de 2021, 20 de julio de 2021 y 13 de marzo de 2022. 
 Ordena los resultados de mayor a menor cantidad.*/

SELECT c.company_name, c.phone, c.country, date(t.timestamp),t.amount
FROM company c INNER JOIN transaction t ON c.id = t.company_id
WHERE t.amount BETWEEN 100 AND 200
AND date(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY t.amount DESC;

-- Ejercicio 2
/* Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, 
por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos
es exigente y quiere un listado de las empresas en las que especifiques si tienen más de 4 transacciones o menos.*/

SELECT t.company_id Empresa,
CASE  
	WHEN COUNT(t.id)  > 4 THEN 'Tiene mas de 4 transacciones'     
	ELSE 'Tiene 4 o menos de 4 transacciones' 
END AS Clasificacion
FROM transaction t 
GROUP BY t.company_id;


