-- nos conectamos a la base de datos
\c proyectococacola;

-- indices por tiempo
CREATE INDEX idx_dia_fecha ON dia(fecha);
CREATE INDEX idx_dia_mes ON dia(mes_id);
CREATE INDEX idx_mes_anio ON mes(anio);

-- indice por geografia
CREATE INDEX idx_ciudad_estado ON ciudad(estado_id);

-- indices por producto 
CREATE INDEX idx_refresco_categoria ON refresco(categoria_id);
CREATE INDEX idx_refresco_sabor ON refresco(sabor_id);

-- indice por clientes
CREATE INDEX idx_tienda_cliente ON tienda(rfc_cliente);

-- indice para agilizar consultas que involucren la cuota de los vendedores
CREATE INDEX idx_vendedor_cuota ON vendedor(cuota_id);

-- indice para buscar por la dimension tiempo con ciudad y producto
CREATE INDEX idx_ventas_dia_ciudad_refresco 
ON ventas(dia_id, ciudad_id, refresco_id);

-- indice para buscar por vendedor y tiempo
CREATE INDEX idx_ventas_vendedor_tiempo 
ON ventas(num_trabajador, dia_id);

-- indice para clientes, tiendas y tiempo
CREATE INDEX idx_ventas_cliente_tienda_dia
ON ventas(rfc_cliente, rfc_tienda, dia_id);

-- indice para producto y tiempo
CREATE INDEX idx_ventas_refresco_tiempo 
ON ventas(refresco_id, dia_id);

-- indice para geografia y tiempo
CREATE INDEX idx_ventas_ciudad_tiempo 
ON ventas(ciudad_id, dia_id);

