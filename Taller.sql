-- Taller | Derivación de tablas a partir de documentos reales
-- Patricia Oquist
-- 30/04/2026


--Creación de la base de datos a partir de la información
-- visible en una factura real de PriceSmart Nicaragua.
CREATE DATABASE FacturacionPriceSmart;
GO

USE FacturacionPriceSmart;
GO

--Tabla Socio:
-- Almacena la información del socio que realiza la compra.
-- El número de socio se mantiene como dato único para identificar al cliente.
CREATE TABLE Socio (
    socio_id INT IDENTITY(1,1) NOT NULL,
    numero_socio VARCHAR(20) NOT NULL,
    nombre_socio VARCHAR(100) NULL,
    tipo_membresia VARCHAR(50) NULL,

    CONSTRAINT PK_Socio PRIMARY KEY (socio_id),
    CONSTRAINT UQ_Socio_Numero UNIQUE (numero_socio)
);
GO

-- Tabla Sucursal:
-- Almacena la información de la sucursal donde se emitió la factura.
CREATE TABLE Sucursal (
    sucursal_id INT IDENTITY(1,1) NOT NULL,
    codigo_sucursal VARCHAR(10) NOT NULL,
    direccion VARCHAR(200) NULL,
    telefono VARCHAR(30) NULL,

    CONSTRAINT PK_Sucursal PRIMARY KEY (sucursal_id),
    CONSTRAINT UQ_Sucursal_Codigo UNIQUE (codigo_sucursal)
);
GO

-- Tabla Producto:
-- Almacena los productos vendidos en la factura.
-- Cada producto se identifica mediante un código único.
CREATE TABLE Producto (
    producto_id INT IDENTITY(1,1) NOT NULL,
    codigo_producto VARCHAR(20) NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Producto PRIMARY KEY (producto_id),
    CONSTRAINT UQ_Producto_Codigo UNIQUE (codigo_producto)
);
GO

-- Tabla Factura:
-- Representa el documento principal de venta.
-- Contiene los datos generales de la factura, los totales y las referencias al socio y a la sucursal.
CREATE TABLE Factura (
    factura_id INT IDENTITY(1,1) NOT NULL,
    numero_factura VARCHAR(30) NOT NULL,
    codigo VARCHAR(20) NULL,
    fecha_hora DATETIME NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    iva DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    cambio DECIMAL(10,2) NOT NULL,
    total_items INT NOT NULL,
    socio_id INT NOT NULL,
    sucursal_id INT NOT NULL,

    CONSTRAINT PK_Factura PRIMARY KEY (factura_id),
    CONSTRAINT UQ_Factura_Numero UNIQUE (numero_factura),

    CONSTRAINT FK_Factura_Socio
        FOREIGN KEY (socio_id) REFERENCES Socio(socio_id),

    CONSTRAINT FK_Factura_Sucursal
        FOREIGN KEY (sucursal_id) REFERENCES Sucursal(sucursal_id)
);
GO


-- Tabla DetalleFactura:
-- Registra cada línea de producto incluida en la factura.
-- Permite relacionar la factura con los productos vendidos, indicando cantidad, precio unitario y total de línea.
CREATE TABLE DetalleFactura (
    detalle_id INT IDENTITY(1,1) NOT NULL,
    factura_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    total_linea DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_DetalleFactura PRIMARY KEY (detalle_id),

    CONSTRAINT FK_DetalleFactura_Factura
        FOREIGN KEY (factura_id) REFERENCES Factura(factura_id),

    CONSTRAINT FK_DetalleFactura_Producto
        FOREIGN KEY (producto_id) REFERENCES Producto(producto_id)
);
GO

-- Tabla Pago:
-- Registra la forma de pago utilizada para cancelar la factura.
-- En el documento que seleccione, el método de pago corresponde a AMEX.
CREATE TABLE Pago (
    pago_id INT IDENTITY(1,1) NOT NULL,
    factura_id INT NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    monto_pagado DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Pago PRIMARY KEY (pago_id),

    CONSTRAINT FK_Pago_Factura
        FOREIGN KEY (factura_id) REFERENCES Factura(factura_id)
);
GO


--Despues verifique las columnas creadas
-- Esta consulta permite revisar los nombres de las tablas, columnas, generados en la base de datos.
USE FacturacionPriceSmart;
GO

SELECT 
    TABLE_NAME AS Tabla,
    COLUMN_NAME AS Columna,
    DATA_TYPE AS TipoDato
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'Socio',
    'Sucursal',
    'Factura',
    'Producto',
    'DetalleFactura',
    'Pago'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;



--Ya sabiendo los nombres de mis columnas, verifique si habian datos registrados
USE FacturacionPriceSmart;
GO

SELECT * FROM Socio;
SELECT * FROM Sucursal;
SELECT * FROM Producto;
SELECT * FROM Factura;
SELECT * FROM DetalleFactura;
SELECT * FROM Pago;


--Como no habian datos tuve que registrarlos
-- Los siguientes registros los tome de la factura seleccionada de PriceSmart.
-- Se insertan datos del socio, sucursal, productos, factura, detalle de productos y pago.
USE FacturacionPriceSmart;
GO


INSERT INTO Socio (
    numero_socio,
    nombre_socio,
    tipo_membresia
)
VALUES (
    '89012368880001',
    'Socio no especificado',
    'Platinum'
);
GO

INSERT INTO Sucursal (
    codigo_sucursal,
    direccion,
    telefono
)
VALUES (
    '8901',
    'Managua, Nicaragua',
    '(505) 7699-8609'
);
GO

INSERT INTO Producto (
    codigo_producto,
    nombre_producto,
    precio_unitario
)
VALUES
('371357', 'Tena Slip G', 1099.95),
('504083', 'Botella', 1449.95),
('487399', 'Lonchera', 619.95),
('48366', 'Pollo Rostizado', 230.39),
('777768', 'MS Toallita', 624.95);
GO

INSERT INTO Factura (
    numero_factura,
    codigo,
    fecha_hora,
    subtotal,
    iva,
    total,
    cambio,
    total_items,
    socio_id,
    sucursal_id
)
SELECT
    '000001839864',
    '0040278',
    '2026-04-29 18:58:00',
    4025.19,
    603.78,
    4628.97,
    0.00,
    5,
    s.socio_id,
    su.sucursal_id
FROM Socio s
CROSS JOIN Sucursal su
WHERE s.numero_socio = '89012368880001'
  AND su.codigo_sucursal = '8901';
GO

INSERT INTO DetalleFactura (
    factura_id,
    producto_id,
    cantidad,
    precio_unitario,
    total_linea
)
SELECT f.factura_id, p.producto_id, 1, 1099.95, 1099.95
FROM Factura f
INNER JOIN Producto p ON p.codigo_producto = '371357'
WHERE f.numero_factura = '000001839864';

INSERT INTO DetalleFactura (
    factura_id,
    producto_id,
    cantidad,
    precio_unitario,
    total_linea
)
SELECT f.factura_id, p.producto_id, 1, 1449.95, 1449.95
FROM Factura f
INNER JOIN Producto p ON p.codigo_producto = '504083'
WHERE f.numero_factura = '000001839864';

INSERT INTO DetalleFactura (
    factura_id,
    producto_id,
    cantidad,
    precio_unitario,
    total_linea
)
SELECT f.factura_id, p.producto_id, 1, 619.95, 619.95
FROM Factura f
INNER JOIN Producto p ON p.codigo_producto = '487399'
WHERE f.numero_factura = '000001839864';

INSERT INTO DetalleFactura (
    factura_id,
    producto_id,
    cantidad,
    precio_unitario,
    total_linea
)
SELECT f.factura_id, p.producto_id, 1, 230.39, 230.39
FROM Factura f
INNER JOIN Producto p ON p.codigo_producto = '48366'
WHERE f.numero_factura = '000001839864';

INSERT INTO DetalleFactura (
    factura_id,
    producto_id,
    cantidad,
    precio_unitario,
    total_linea
)
SELECT f.factura_id, p.producto_id, 1, 624.95, 624.95
FROM Factura f
INNER JOIN Producto p ON p.codigo_producto = '777768'
WHERE f.numero_factura = '000001839864';
GO

INSERT INTO Pago (
    factura_id,
    metodo_pago,
    monto_pagado
)
SELECT
    factura_id,
    'AMEX',
    4628.97
FROM Factura
WHERE numero_factura = '000001839864';
GO


-- Despues de ingresar, hice una verificación de datos insertados.
-- Esta consulta permite comprobar que los registros fueron guardados correctamente.

SELECT * FROM Socio;
SELECT * FROM Sucursal;
SELECT * FROM Producto;
SELECT * FROM Factura;
SELECT * FROM DetalleFactura;
SELECT * FROM Pago;
GO



--Despues de todos estos pasos, mi consulta final seria esta
-- Esta consulta reconstruye la información principal de la factura seleccionada.
-- Une las tablas Socio, Sucursal, Factura, DetalleFactura, Producto y Pago para
-- mostrar los datos utilizados en el documento base.


USE FacturacionPriceSmart;
GO

SELECT
    f.numero_factura AS [Número de Factura],
    f.codigo AS [Código],
    f.fecha_hora AS [Fecha y Hora],

    s.numero_socio AS [Número de Socio],
    s.nombre_socio AS [Nombre del Socio],
    s.tipo_membresia AS [Tipo de Membresía],

    su.codigo_sucursal AS [Código de Sucursal],
    su.direccion AS [Dirección de Sucursal],
    su.telefono AS [Teléfono],

    p.codigo_producto AS [Código de Producto],
    p.nombre_producto AS [Producto],
    df.cantidad AS [Cantidad],
    df.precio_unitario AS [Precio Unitario],
    df.total_linea AS [Total Línea],

    f.subtotal AS [Subtotal],
    f.iva AS [IVA],
    f.total AS [Total Factura],
    f.cambio AS [Cambio],
    f.total_items AS [Total de Ítems],

    pg.metodo_pago AS [Método de Pago],
    pg.monto_pagado AS [Monto Pagado]
FROM Factura f
INNER JOIN Socio s
    ON f.socio_id = s.socio_id
INNER JOIN Sucursal su
    ON f.sucursal_id = su.sucursal_id
INNER JOIN DetalleFactura df
    ON f.factura_id = df.factura_id
INNER JOIN Producto p
    ON df.producto_id = p.producto_id
INNER JOIN Pago pg
    ON f.factura_id = pg.factura_id
WHERE f.numero_factura = '000001839864';