-- i) A la Compania le interesa saber que ciudad es la que vende más, de esas ventas qué refresco se vende más y que vendedor es el que ha vendido más de ese refresco en los últimos dos años.


-- Obtenemos ciudad que mas vende, refresco mas vendido en esa ciudad, y mejor vendedor de ESE refresco
SELECT 
    ciudad_top.ciudad_desc AS "Ciudad que más vende",
    refresco_top.refresco_desc AS "Refresco más vendido",
    vendedor_top.nombre_v AS "Mejor vendedor del refresco",
    refresco_top.total_refresco AS "Total refresco vendido",
    vendedor_top.ventas_vendedor AS "Ventas del vendedor"
FROM (
    -- Seleccionamos la ciudad que mas vende en los ultimos 2 años
    SELECT ci.ciudad_id, ci.ciudad_desc
    FROM ventas v
    JOIN ciudad ci ON v.ciudad_id = ci.ciudad_id
    JOIN dia d ON v.dia_id = d.dia_id
    JOIN mes m ON d.mes_id = m.mes_id
    JOIN anio a ON m.anio = a.anio
    WHERE a.anio >= (SELECT MAX(anio) FROM anio) - 1
    GROUP BY ci.ciudad_id, ci.ciudad_desc
    ORDER BY SUM(v.cantidad_venta) DESC
    LIMIT 1 -- es para que solo nos salga un registro
) ciudad_top
JOIN (
    -- Obtenemos el refresco mas vendido en ESA ciudad especifica
    SELECT v.ciudad_id, r.refresco_id, r.refresco_desc, SUM(v.cantidad_venta) as total_refresco
    FROM ventas v
    JOIN refresco r ON v.refresco_id = r.refresco_id
    JOIN dia d ON v.dia_id = d.dia_id
    JOIN mes m ON d.mes_id = m.mes_id
    JOIN anio a ON m.anio = a.anio
    WHERE a.anio >= (SELECT MAX(anio) FROM anio) - 1
    GROUP BY v.ciudad_id, r.refresco_id, r.refresco_desc
) refresco_top ON ciudad_top.ciudad_id = refresco_top.ciudad_id
JOIN (
    -- Obtenemos el mejor vendedor de ESE refresco especifico en ESA ciudad especifica
    SELECT v.ciudad_id, v.refresco_id, ve.num_trabajador, ve.nombre_v, SUM(v.cantidad_venta) as ventas_vendedor
    FROM ventas v
    JOIN vendedor ve ON v.num_trabajador = ve.num_trabajador
    JOIN dia d ON v.dia_id = d.dia_id
    JOIN mes m ON d.mes_id = m.mes_id
    JOIN anio a ON m.anio = a.anio
    WHERE a.anio >= (SELECT MAX(anio) FROM anio) - 1
    GROUP BY v.ciudad_id, v.refresco_id, ve.num_trabajador, ve.nombre_v
) vendedor_top ON refresco_top.ciudad_id = vendedor_top.ciudad_id 
               AND refresco_top.refresco_id = vendedor_top.refresco_id
-- Filtro para quedarnos solo con el refresco mas vendido de esa ciudad
WHERE refresco_top.total_refresco = (
    SELECT MAX(total_refresco) 
    FROM (
        SELECT v.ciudad_id, r.refresco_id, SUM(v.cantidad_venta) as total_refresco
        FROM ventas v
        JOIN refresco r ON v.refresco_id = r.refresco_id
        JOIN dia d ON v.dia_id = d.dia_id
        JOIN mes m ON d.mes_id = m.mes_id
        JOIN anio a ON m.anio = a.anio
        WHERE a.anio >= (SELECT MAX(anio) FROM anio) - 1
        AND v.ciudad_id = ciudad_top.ciudad_id
        GROUP BY v.ciudad_id, r.refresco_id
    ) sub
    WHERE sub.ciudad_id = ciudad_top.ciudad_id
)
-- Filtro para quedarme solo con el mejor vendedor de ese refresco
AND vendedor_top.ventas_vendedor = (
    SELECT MAX(ventas_vendedor) 
    FROM (
        SELECT v.ciudad_id, v.refresco_id, ve.num_trabajador, SUM(v.cantidad_venta) as ventas_vendedor
        FROM ventas v
        JOIN vendedor ve ON v.num_trabajador = ve.num_trabajador
        JOIN dia d ON v.dia_id = d.dia_id
        JOIN mes m ON d.mes_id = m.mes_id
        JOIN anio a ON m.anio = a.anio
        WHERE a.anio >= (SELECT MAX(anio) FROM anio) - 1
        AND v.ciudad_id = ciudad_top.ciudad_id
        AND v.refresco_id = refresco_top.refresco_id
        GROUP BY v.ciudad_id, v.refresco_id, ve.num_trabajador
    ) sub2
    WHERE sub2.ciudad_id = ciudad_top.ciudad_id 
    AND sub2.refresco_id = refresco_top.refresco_id
)
ORDER BY vendedor_top.ventas_vendedor DESC
LIMIT 1; -- solo obtendremos el 1 registro






-- ii) Se desea saber que ciudad tiene mas ordenes de compra y quien es su cliente que mas refrescos compra.
 
-- Obtendremos la ciudad con mas ordenes y su cliente que mas compra
SELECT 
    ciudad_ordenes.ciudad_desc AS "Ciudad con más órdenes",
    cliente_compras.cliente_nombre AS "Cliente que más compra",
    ciudad_ordenes.total_ordenes AS "Total órdenes",
    cliente_compras.total_compras AS "Total refrescos comprados"
FROM (
    -- Averiguamos la ciudad con mas ordenes
    SELECT ci.ciudad_desc, ci.ciudad_id, COUNT(*) as total_ordenes
    FROM ventas v
    JOIN ciudad ci ON v.ciudad_id = ci.ciudad_id
    GROUP BY ci.ciudad_desc, ci.ciudad_id
    ORDER BY COUNT(*) DESC
    LIMIT 1 -- nos quedamos con la maxima
) ciudad_ordenes
JOIN (
    -- Obtenemos el cliente que mas compra en esa ciudad
    SELECT v.ciudad_id, c.cliente_nombre, SUM(v.cantidad_venta) as total_compras
    FROM ventas v
    JOIN cliente c ON v.rfc_cliente = c.rfc_cliente
    GROUP BY v.ciudad_id, c.cliente_nombre
    ORDER BY SUM(v.cantidad_venta) DESC
    LIMIT 1 -- nos quedamos con solo ESE cliente
) cliente_compras ON ciudad_ordenes.ciudad_id = cliente_compras.ciudad_id;





-- iii) Se desea saber en que mes del anio se vende mas refresco y en particular que dia del anio se vende mas refresco.

SELECT 
    mes_top.mes_desc AS "Mes con más ventas",
    mes_top.anio AS "Año del mes",
    mes_top.ventas_mes AS "Ventas del mes",
    dia_top.fecha AS "Día con más ventas", 
    dia_top.ventas_dia AS "Ventas del día"
FROM (
    -- Obtenemos el mes con mas ventas
    SELECT m.mes_desc, a.anio, SUM(v.cantidad_venta) as ventas_mes
    FROM ventas v
    JOIN dia d ON v.dia_id = d.dia_id
    JOIN mes m ON d.mes_id = m.mes_id
    JOIN anio a ON m.anio = a.anio
    GROUP BY m.mes_desc, a.anio
    ORDER BY SUM(v.cantidad_venta) DESC
    LIMIT 1
) mes_top,
(
    -- Vemos el dia con mas ventas
    SELECT d.fecha, SUM(v.cantidad_venta) as ventas_dia
    FROM ventas v
    JOIN dia d ON v.dia_id = d.dia_id
    GROUP BY d.fecha
    ORDER BY SUM(v.cantidad_venta) DESC
    LIMIT 1
) dia_top;


-- iv) Para evitar producir refrescos que no generan ganancias, desea saber que refresco es el que menos se ha vendido en los ultimos dos anios. 


-- Deseamos obtener el refresco menos vendido en los 2 ultimos anios
SELECT 
    r.refresco_desc AS "Refresco menos vendido",
    c.categoria_desc AS "Categoria",
    s.sabor_desc AS "Sabor",
    SUM(v.cantidad_venta) AS "Total vendido"
FROM ventas v
JOIN refresco r ON v.refresco_id = r.refresco_id
JOIN categoria c ON r.categoria_id = c.categoria_id
JOIN sabor s ON r.sabor_id = s.sabor_id
JOIN dia d ON v.dia_id = d.dia_id
JOIN mes m ON d.mes_id = m.mes_id
JOIN anio a ON m.anio = a.anio
WHERE a.anio >= (SELECT MAX(anio) FROM anio) - 1
GROUP BY r.refresco_desc, c.categoria_desc, s.sabor_desc
ORDER BY SUM(v.cantidad_venta) ASC
LIMIT 1; -- solo nos interesa 1 refresco


-- CONSULTAS EXTRA

-- v) Mostrar las ventas de refrescos de sabor Cola Original, en la categoria Refresco Regular, solo para los meses de diciembre a febrero durante los últimos 2 anios

SELECT 
    m.anio,
    m.mes_desc AS mes,
    c.categoria_desc AS categoria,
    s.sabor_desc AS sabor,
    SUM(v.cantidad_venta) AS total_unidades_vendidas,
    SUM(v.venta_$) AS total_ventas_dinero
FROM ventas v
INNER JOIN dia d ON v.dia_id = d.dia_id
INNER JOIN mes m ON d.mes_id = m.mes_id
INNER JOIN refresco r ON v.refresco_id = r.refresco_id
INNER JOIN categoria c ON r.categoria_id = c.categoria_id
INNER JOIN sabor s ON r.sabor_id = s.sabor_id
WHERE 
    m.anio IN (2023, 2024)  -- Últimos 2 años
    AND s.sabor_desc IN ('Cola Original')  -- Filtro DICE en sabor
    AND c.categoria_desc IN ('Refresco Regular')  -- Filtro DICE en categoria
    AND m.mes_desc IN ('Diciembre', 'Enero', 'Febrero')  -- Filtro DICE en meses específicos
GROUP BY m.anio, m.mes_desc, c.categoria_desc, s.sabor_desc
ORDER BY 
    m.anio,
    CASE 
        WHEN m.mes_desc = 'Diciembre' THEN 1
        WHEN m.mes_desc = 'Enero' THEN 2
        WHEN m.mes_desc = 'Febrero' THEN 3
    END,
    total_unidades_vendidas DESC;


-- vi) La empresa quiere conocer el desempenio de sus vendedores respecto a sus cuotas asignadas para garantizar que se esten cumpliendo sus metas, para que de lo contrario se puedan tomar acciones para mejorar.

-- Buscamos desempenio de vendedores vs cuotas MENSUALES
-- NOTA: la cuota que se almacena la consideramos como la cuota MENSUAL entonces comparamos directamente con ella

WITH cuotas_mensuales AS (
    -- Seleccionamos la cuota mensual
    SELECT 
        vd.num_trabajador,
        vd.nombre_v,
        c.cuota_desc::NUMERIC as cuota_mensual
    FROM vendedor vd
    JOIN cuota c ON vd.cuota_id = c.cuota_id
    WHERE c.cuota_desc > 0::MONEY  -- Filtro para cuotas positivas
),
ventas_mensuales AS (
    -- Ventas reales por vendedor y mes
    SELECT 
        v.num_trabajador,
        m.mes_desc,
        a.anio,
        SUM(v.cantidad_venta) as unidades_vendidas,
        SUM(v.venta_$) as ingresos_reales,
        COUNT(DISTINCT v.dia_id) as dias_trabajados,
        COUNT(*) as total_transacciones
    FROM ventas v
    JOIN dia d ON v.dia_id = d.dia_id
    JOIN mes m ON d.mes_id = m.mes_id
    JOIN anio a ON m.anio = a.anio
    WHERE a.anio >= (SELECT MAX(anio) FROM anio) - 1
    GROUP BY v.num_trabajador, m.mes_desc, a.anio
)
SELECT 
    vm.mes_desc AS "Mes",
    vm.anio AS "Año",
    vd.nombre_v AS "Vendedor",
    cm.cuota_mensual AS "Cuota Mensual Asignada",
    vm.ingresos_reales AS "Ingresos Reales",
    vm.unidades_vendidas AS "Unidades Vendidas",
    
    -- Verificamos el cumplimiento de las cuotas
    ROUND((vm.ingresos_reales::NUMERIC / cm.cuota_mensual) * 100, 2) AS "% Cumplimiento Cuota",
    
    -- Estado de desempeño
    CASE 
        WHEN vm.ingresos_reales::NUMERIC >= cm.cuota_mensual * 1.2 THEN '¡Sobresaliente!'
        WHEN vm.ingresos_reales::NUMERIC >= cm.cuota_mensual THEN 'Cumplió'
        WHEN vm.ingresos_reales::NUMERIC >= cm.cuota_mensual * 0.8 THEN 'Cercano a Meta de Cuota'
        WHEN vm.ingresos_reales::NUMERIC >= cm.cuota_mensual * 0.6 THEN '¡Atención!'
        ELSE 'Por Debajo de Meta'
    END AS "Estado Desempeño",
    
    -- Diferencia vs cuota
    ROUND(vm.ingresos_reales::NUMERIC - cm.cuota_mensual, 2) AS "Diferencia vs Cuota"
    
FROM ventas_mensuales vm
JOIN cuotas_mensuales cm ON vm.num_trabajador = cm.num_trabajador
JOIN vendedor vd ON vm.num_trabajador = vd.num_trabajador
ORDER BY 
    vm.anio,
    CASE vm.mes_desc 
        WHEN 'Enero' THEN 1 WHEN 'Febrero' THEN 2 WHEN 'Marzo' THEN 3 
        WHEN 'Abril' THEN 4 WHEN 'Mayo' THEN 5 WHEN 'Junio' THEN 6
        WHEN 'Julio' THEN 7 WHEN 'Agosto' THEN 8 WHEN 'Septiembre' THEN 9
        WHEN 'Octubre' THEN 10 WHEN 'Noviembre' THEN 11 WHEN 'Diciembre' THEN 12
    END,
    (vm.ingresos_reales::NUMERIC / cm.cuota_mensual) DESC;

-- vii) La empresa desea saber las ventas de refrescos cada mes (columnas) por categoria de refrescos (filas).


SELECT 
    cat.categoria_desc AS "Categoría",
    
    -- Aquí ocurre la ROTACIÓN (Pivot): Convertimos los meses en columnas
    SUM(CASE WHEN m.mes_desc = 'Enero'      THEN v.venta_$ ELSE 0::MONEY END) AS "Enero",
    SUM(CASE WHEN m.mes_desc = 'Febrero'    THEN v.venta_$ ELSE 0::MONEY END) AS "Febrero",
    SUM(CASE WHEN m.mes_desc = 'Marzo'      THEN v.venta_$ ELSE 0::MONEY END) AS "Marzo",
    SUM(CASE WHEN m.mes_desc = 'Abril'      THEN v.venta_$ ELSE 0::MONEY END) AS "Abril",
    SUM(CASE WHEN m.mes_desc = 'Mayo'       THEN v.venta_$ ELSE 0::MONEY END) AS "Mayo",
    SUM(CASE WHEN m.mes_desc = 'Junio'      THEN v.venta_$ ELSE 0::MONEY END) AS "Junio",
    SUM(CASE WHEN m.mes_desc = 'Julio'      THEN v.venta_$ ELSE 0::MONEY END) AS "Julio",
    SUM(CASE WHEN m.mes_desc = 'Agosto'     THEN v.venta_$ ELSE 0::MONEY END) AS "Agosto",
    SUM(CASE WHEN m.mes_desc = 'Septiembre' THEN v.venta_$ ELSE 0::MONEY END) AS "Septiembre",
    SUM(CASE WHEN m.mes_desc = 'Octubre'    THEN v.venta_$ ELSE 0::MONEY END) AS "Octubre",
    SUM(CASE WHEN m.mes_desc = 'Noviembre'  THEN v.venta_$ ELSE 0::MONEY END) AS "Noviembre",
    SUM(CASE WHEN m.mes_desc = 'Diciembre'  THEN v.venta_$ ELSE 0::MONEY END) AS "Diciembre",
    
    -- Columna totalizadora (opcional pero recomendada en pivots)
    SUM(v.venta_$) AS "Total Anual"

FROM ventas v
JOIN refresco r ON v.refresco_id = r.refresco_id
JOIN categoria cat ON r.categoria_id = cat.categoria_id
JOIN dia d ON v.dia_id = d.dia_id
JOIN mes m ON d.mes_id = m.mes_id
JOIN anio a ON m.anio = a.anio

-- Filtramos para analizar solo el último año disponible (Slice implícito)
WHERE a.anio = (SELECT MAX(anio) FROM anio)

GROUP BY cat.categoria_desc
ORDER BY "Total Anual" DESC;


-- viii) La empresa desea saber cuales fueron las ventas por ciudad, cuales fueron los totales por estado y cual fue la venta total.

SELECT 
    e.estado_desc AS "Estado",
    ci.ciudad_desc AS "Ciudad",
    SUM(v.venta_$) AS "Ventas Totales"
FROM ventas v
JOIN ciudad ci ON v.ciudad_id = ci.ciudad_id
JOIN estado e ON ci.estado_id = e.estado_id

-- ROLLUP genera las filas extra con los totales automáticamente
GROUP BY ROLLUP (e.estado_desc, ci.ciudad_desc)

ORDER BY e.estado_desc, ci.ciudad_desc;








