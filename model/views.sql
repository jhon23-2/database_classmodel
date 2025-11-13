USE classicmodels;

-- ===========================================
-- Vista Productos con margen alto 
-- ===========================================

CREATE OR REPLACE VIEW Vista_Margen_Alto AS
SELECT 
    p.productCode AS productCode,
    p.productName AS productName,
    p.productLine,
    p.buyPrice,
    p.MSRP,
    -- Cálculo del margen bruto en valor monetario
    (p.MSRP - p.buyPrice) AS MargenBruto,
    -- Cálculo del margen bruto en porcentaje
    ROUND(((p.MSRP - p.buyPrice) / p.buyPrice * 100), 2) AS MargenPorcentaje,
    p.quantityInStock,
    p.productVendor
FROM 
    products p
WHERE 
    -- Filtro: Solo productos con margen superior al promedio
    (p.MSRP - p.buyPrice) > (
        SELECT AVG(MSRP - buyPrice) 
        FROM products
    )
ORDER BY 
    MargenBruto DESC;


-- ===========================================
-- Vista de Contactos de Clientes
-- ===========================================
CREATE OR REPLACE VIEW Vista_Contactos_Soporte AS
SELECT
    customerName AS NombreCompania,
    CONCAT(contactFirstName, ' ', contactLastName) AS NombreContacto,
    phone AS Telefono,
    CONCAT(city, ', ', country) AS CiudadPais
FROM
    customers;

-- ===========================================
-- Vista de Pedidos Pendientes
-- ===========================================
CREATE OR REPLACE VIEW Vista_Pedidos_Pendientes AS
SELECT
    o.orderNumber AS NumeroPedido,
    c.customerName AS NombreCliente,
    od.productCode AS CodigoProducto,
    od.quantityOrdered AS CantidadPendiente,
    o.requiredDate AS FechaRequerida
FROM
    orders o
INNER JOIN
    orderdetails od ON o.orderNumber = od.orderNumber
INNER JOIN
    customers c ON o.customerNumber = c.customerNumber
WHERE
    o.status <> 'Shipped';

-- ===========================================
-- Vista de Desempeño por Oficina
-- ===========================================
CREATE OR REPLACE VIEW Vista_Desempeno_Oficina AS
SELECT
    o.city AS Ciudad,
    COUNT(DISTINCT e.employeeNumber) AS TotalEmpleados,
    SUM(od.quantityOrdered * od.priceEach) AS VentasOficina
FROM
    offices o
LEFT JOIN
    employees e ON o.officeCode = e.officeCode
LEFT JOIN
    customers c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN
    orders ord ON c.customerNumber = ord.customerNumber
LEFT JOIN
    orderdetails od ON ord.orderNumber = od.orderNumber
WHERE
    ord.status = 'Shipped'
GROUP BY
    o.city;

-- ===========================================
-- Identificación de Oficinas con Bajo Rendimiento
-- ===========================================

-- Nivel 1: Ventas por empleado
CREATE OR REPLACE VIEW Vista_Ventas_x_Empleado AS
SELECT
    e.employeeNumber,
    e.officeCode,
    SUM(od.quantityOrdered * od.priceEach) AS TotalVentas
FROM
    employees e
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE
    o.status = 'Shipped'
GROUP BY
    e.employeeNumber, e.officeCode;

-- Nivel 2: Promedio de ventas por oficina
CREATE OR REPLACE VIEW Vista_Promedio_Oficina AS
SELECT
    officeCode,
    AVG(TotalVentas) AS PromedioVentasPorEmpleado
FROM
    Vista_Ventas_x_Empleado
GROUP BY
    officeCode;

-- Consulta final sugerida
-- (no se crea como vista porque depende de una subconsulta)
-- SELECT o.city, vpo.PromedioVentasPorEmpleado
-- FROM Vista_Promedio_Oficina vpo
-- JOIN offices o ON vpo.officeCode = o.officeCode
-- WHERE vpo.PromedioVentasPorEmpleado < (
--     SELECT AVG(PromedioVentasPorEmpleado)
--     FROM Vista_Promedio_Oficina
-- );

-- ===========================================
-- Catálogo de Productos con Stock Crítico
-- ===========================================

-- Nivel 1: Productos con poco stock
CREATE OR REPLACE VIEW Vista_Stock_Critico AS
SELECT
    productCode,
    productName,
    quantityInStock,
    buyPrice,
    MSRP
FROM
    products
WHERE
    quantityInStock < 1000;

-- Nivel 2: Productos con precio máximo dentro del stock crítico
CREATE OR REPLACE VIEW Vista_Precios_Maximos AS
SELECT *
FROM Vista_Stock_Critico
WHERE buyPrice = (SELECT MAX(buyPrice) FROM Vista_Stock_Critico);

-- ===========================================
-- Clientes con Mayor Gasto en Producto Único
-- ===========================================

-- Nivel 1: Monto máximo por pedido
CREATE OR REPLACE VIEW Vista_Max_x_Pedido AS
SELECT
    orderNumber,
    MAX(quantityOrdered * priceEach) AS MontoTotalProducto
FROM
    orderdetails
GROUP BY
    orderNumber;

-- Nivel 2: Máximo valor de pedido por cliente
CREATE OR REPLACE VIEW Vista_Max_x_Cliente AS
SELECT
    c.customerName,
    MAX(vmp.MontoTotalProducto) AS PedidoMasCaro
FROM
    Vista_Max_x_Pedido vmp
JOIN orders o ON vmp.orderNumber = o.orderNumber
JOIN customers c ON o.customerNumber = c.customerNumber
GROUP BY
    c.customerName;
