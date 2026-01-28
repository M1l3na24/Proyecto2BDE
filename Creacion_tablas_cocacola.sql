-- Entramos a la base de datos
\c proyectococacola;


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
    cuota_desc VARCHAR(100)
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
    FOREIGN KEY (sabor_id) 
REFERENCES sabor(sabor_id)
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
)


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

-- TABLA DE HECHOS

CREATE TABLE ventas (
    ciudad_id INT,
    num_trabajador INT,
    refresco_id INT,
    rfc_cliente CHAR(13),
    rfc_tienda CHAR(13),
    dia_id INT,
    cantidad_venta INT,
    venta_$ MONEY

    FOREIGN KEY (ciudad_id) REFERENCES ciudad(ciudad_id),
    FOREIGN KEY (num_trabajador) REFERENCES vendedor(num_tranajador),
    FOREIGN KEY (refresco_id) REFERENCES refresco(refresco_id),
    FOREIGN KEY (rfc_cliente) REFERENCES cliente(rfc),
    FOREIGN KEY (rfc_tienda) REFERENCES tienda(rfc_tienda),
    FOREIGN KEY (dia_id) REFERENCES dia(dia_id)
);
