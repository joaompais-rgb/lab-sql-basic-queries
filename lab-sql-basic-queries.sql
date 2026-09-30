-- =====================================================================
-- Lab | SQL Basic Queries (base de datos sakila)
-- Cada ejercicio lleva: qué hace la consulta, por qué así y qué alternativa descarto.
-- =====================================================================

-- Seleccionar la base de datos. Así no hace falta escribir sakila.tabla en cada consulta.
USE sakila;


-- ---------------------------------------------------------------------
-- 1. Mostrar todas las tablas de la base de datos
-- ---------------------------------------------------------------------
-- SHOW TABLES lista las tablas (y las vistas) de la base de datos activa.
-- Alternativa: consultar information_schema.tables, útil si quiero filtrar
-- o contar tablas, pero para verlas SHOW TABLES es lo más directo.
SHOW TABLES;


-- ---------------------------------------------------------------------
-- 2. Todos los datos de las tablas actor, film y customer
-- ---------------------------------------------------------------------
-- SELECT * devuelve todas las columnas. Está bien para explorar una tabla;
-- en consultas "de verdad" es mejor nombrar las columnas que necesito,
-- porque es más claro y más rápido.
SELECT * FROM actor;
SELECT * FROM film;
SELECT * FROM customer;


-- ---------------------------------------------------------------------
-- 3. Columnas concretas
-- ---------------------------------------------------------------------
-- 3.1 Títulos de todas las películas
SELECT title
FROM film;

-- 3.2 Idiomas, con la columna renombrada como "language".
-- AS da un alias: cambia el nombre de la columna en el resultado, no en la tabla.
SELECT name AS language
FROM language;

-- 3.3 Nombres de todos los empleados
SELECT first_name
FROM staff;


-- ---------------------------------------------------------------------
-- 4. Años de estreno únicos
-- ---------------------------------------------------------------------
-- DISTINCT elimina las filas repetidas del resultado.
-- Resultado: solo aparece 2006, todas las películas son de ese año.
SELECT DISTINCT release_year
FROM film;


-- ---------------------------------------------------------------------
-- 5. Contar registros
-- ---------------------------------------------------------------------
-- 5.1 Número de tiendas. COUNT(*) cuenta filas: cada fila de store es una tienda. Resultado: 2.
SELECT COUNT(*) AS number_of_stores
FROM store;

-- 5.2 Número de empleados. Resultado: 2.
SELECT COUNT(*) AS number_of_employees
FROM staff;

-- 5.3 Películas disponibles para alquilar y películas alquiladas.
-- "Disponible para alquilar" = que tiene al menos una copia en el inventario.
-- Cuento dos cosas en cada caso, porque la pregunta se puede leer de dos formas:
--   - copias (filas de inventory) y títulos distintos (film_id distintos).
-- COUNT(DISTINCT columna) cuenta valores distintos, sin repetir.
-- Resultado: 4581 copias de 958 títulos distintos (42 de las 1000 películas no tienen copias).
SELECT COUNT(*)                AS copies_in_inventory,
       COUNT(DISTINCT film_id) AS films_available
FROM inventory;

-- Alquiladas: cada fila de rental es un alquiler. Para saber cuántos títulos distintos
-- se han alquilado necesito film_id, que está en inventory, así que uno las dos tablas
-- por inventory_id (los JOIN se ven en detalle en el lab de joins).
-- Resultado: 16044 alquileres de 958 títulos distintos.
SELECT COUNT(*)                  AS total_rentals,
       COUNT(DISTINCT i.film_id) AS films_rented
FROM rental AS r
JOIN inventory AS i ON r.inventory_id = i.inventory_id;

-- 5.4 Número de apellidos distintos de los actores. Resultado: 121.
SELECT COUNT(DISTINCT last_name) AS distinct_last_names
FROM actor;


-- ---------------------------------------------------------------------
-- 6. Las 10 películas más largas
-- ---------------------------------------------------------------------
-- ORDER BY length DESC ordena de mayor a menor duración y LIMIT 10 se queda con las 10 primeras.
-- Nota: hay exactamente 10 películas con la duración máxima (185 minutos), así que las 10
-- empatan. Añado title como segundo criterio de orden para que el resultado sea siempre
-- el mismo; sin él, MySQL puede devolver los empates en cualquier orden.
SELECT title, length
FROM film
ORDER BY length DESC, title
LIMIT 10;


-- ---------------------------------------------------------------------
-- 7. Filtros
-- ---------------------------------------------------------------------
-- 7.1 Actores con el nombre SCARLETT. WHERE filtra filas; = busca el valor exacto.
-- Resultado: SCARLETT DAMON y SCARLETT BENING.
SELECT *
FROM actor
WHERE first_name = 'SCARLETT';

-- BONUS
-- 7.2 Películas con ARMAGEDDON en el título y más de 100 minutos.
-- LIKE con % busca un patrón: '%ARMAGEDDON%' significa "cualquier texto, ARMAGEDDON, cualquier texto",
-- así encuentra la palabra en cualquier posición del título. AND exige que se cumplan las dos condiciones.
-- Resultado: 4 películas.
SELECT title, length
FROM film
WHERE title LIKE '%ARMAGEDDON%'
  AND length > 100;

-- 7.3 Número de películas con contenido "Behind the Scenes".
-- special_features guarda varios valores separados por comas (por ejemplo "Trailers,Behind the Scenes").
-- Con LIKE '%Behind the Scenes%' encuentro el texto aunque vaya acompañado de otros.
-- Alternativa específica de MySQL: FIND_IN_SET('Behind the Scenes', special_features) > 0,
-- que busca el elemento exacto dentro de la lista separada por comas.
-- Resultado: 538.
SELECT COUNT(*) AS films_with_behind_the_scenes
FROM film
WHERE special_features LIKE '%Behind the Scenes%';
