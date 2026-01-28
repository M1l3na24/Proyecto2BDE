-- creamos una nueva base de datos pero columnar
CREATE DATABASE proyectococacola_columnar;

-- entramos a la base de datos nueva
\c proyectococacola_columnar

-- habilitamos la extension
CREATE EXTENSION IF NOT EXISTS cstore_fdw;

-- conectamos al motor columnar 
CREATE SERVER dw_columnar FOREIGN DATA WRAPPER cstore_fdw;

-- creamos las tablas que teniamos 

-- DIMENSIÓN GEOGRAFÍA

CREATE TABLE estado (
    estado_id INT PRIMARY KEY,
    estado_desc VARCHAR(100)
);

CREATE TABLE ciudad (
    ciudad_id INT PRIMARY KEY,
    ciudad_desc VARCHAR(100),
    estado_id INT,
    FOREIGN KEY (estado_id) REFERENCES estado(estado_id)
);


-- DIMENSIÓN VENDEDOR

CREATE TABLE cuota(
    cuota_id INT PRIMARY KEY,
    cuota_desc MONEY
);

CREATE TABLE vendedor (
    num_trabajador INT PRIMARY KEY,
    nombre_v VARCHAR(100),
    cuota_id INT,
    FOREIGN KEY (cuota_id) REFERENCES
cuota(cuota_id)     
);

-- DIMENSIÓN PRODUCTO

CREATE TABLE categoria (
    categoria_id INT PRIMARY KEY,
    categoria_desc VARCHAR(100)
);

CREATE TABLE sabor (
    sabor_id INT PRIMARY KEY,
    sabor_desc VARCHAR(100)
);

CREATE TABLE refresco (
    refresco_id INT PRIMARY KEY,
    refresco_desc VARCHAR(100),
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES categoria(categoria_id),
    sabor_id INT,
    FOREIGN KEY (sabor_id) REFERENCES sabor(sabor_id)
);

-- DIMENSIÓN CLIENTE--

CREATE TABLE cliente (
    rfc_cliente CHAR(13) PRIMARY KEY,
    cliente_nombre VARCHAR(100)
);

CREATE TABLE tienda (
    rfc_tienda CHAR(13) PRIMARY KEY,
    tienda_nombre VARCHAR(100),
    rfc_cliente CHAR(13),
    FOREIGN KEY (rfc_cliente) 
REFERENCES cliente(rfc_cliente)
);

CREATE TABLE direccion (
    direccion_id INT PRIMARY KEY,
    direccion_desc VARCHAR(100),
    rfc_tienda CHAR(13),
    FOREIGN KEY (rfc_tienda)
REFERENCES tienda(rfc_tienda)
);

-- DIMENSIÓN TIEMPO

CREATE TABLE anio (
    anio INT PRIMARY KEY
);

CREATE TABLE mes (
    mes_id INT PRIMARY KEY,
    mes_desc VARCHAR(20),
    anio INT,
    FOREIGN KEY (anio) REFERENCES anio(anio)
);

CREATE TABLE dia (
    dia_id INT PRIMARY KEY,
    fecha DATE,
    mes_id INT,
    FOREIGN KEY (mes_id) REFERENCES mes(mes_id)
);

-- Nota: NO se definen FOREIGN KEYs 
-- La integridad de los datos la garantiza el proceso de carga (ETL)

CREATE FOREIGN TABLE ventas (
    ciudad_id INT,
    num_trabajador INT,
    refresco_id INT,
    rfc_cliente CHAR(13),
    rfc_tienda CHAR(13),
    dia_id INT,
    cantidad_venta INT,
    venta_$ MONEY
)
SERVER dw_columnar;

-- los csv con los registros ya deben estar cargado en el servidor
-- cargamos los registros 
\c proyectococacola_columnar

\copy categoria from
'/home/alumno06/Archivos/Columnar/registros_categoria_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy sabor from
'/home/alumno06/Archivos/Columnar/registros_sabor_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy refresco from
'/home/alumno06/Archivos/Columnar/registros_refrescos_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy estado from
'/home/alumno06/Archivos/Columnar/registros_estados_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy ciudad from
'/home/alumno06/Archivos/Columnar/registros_ciudad_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy cuota from
'/home/alumno06/Archivos/Columnar/registros_cuota_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy anio from
'/home/alumno06/Archivos/Columnar/registros_anio_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy mes from
'/home/alumno06/Archivos/Columnar/registros_mes_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy dia from
'/home/alumno06/Archivos/Columnar/registros_dia_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy dia from
'/home/alumno06/Archivos/Columnar/registros_dia_2024.csv' WITH DELIMITER ',' CSV HEADER;

\copy cliente from
'/home/alumno06/Archivos/Columnar/registros_clientes_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy tienda from
'/home/alumno06/Archivos/Columnar/registros_tienda_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy direccion from
'/home/alumno06/Archivos/Columnar/registros_direccion_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy vendedor from
'/home/alumno06/Archivos/Columnar/registros_vendedores_cocacola.csv' WITH DELIMITER ',' CSV HEADER;

\copy ventas from
'/home/alumno06/Archivos/Columnar/ventas_actualizadas.csv' WITH DELIMITER ',' CSV HEADER;

\copy ventas from
'/home/alumno06/Archivos/Columnar/ventas_adicionales_2024.csv' WITH DELIMITER ',' CSV HEADER;


-- revisamos que se hayan cargado correctamente
SELECT * FROM estado LIMIT 10;

SELECT * FROM ciudad LIMIT 10;

SELECT * FROM vendedor LIMIT 10;

SELECT * FROM cuota LIMIT 10;

SELECT * FROM categoria LIMIT 10;

SELECT * FROM refresco LIMIT 10;

SELECT * FROM sabor LIMIT 10;

SELECT * FROM direccion LIMIT 10;

SELECT * FROM cliente LIMIT 10;

SELECT * FROM tienda LIMIT 10;

SELECT * FROM anio LIMIT 10;

SELECT * FROM mes LIMIT 10;

SELECT * FROM dia LIMIT 10;

SELECT * FROM ventas LIMIT 10;


