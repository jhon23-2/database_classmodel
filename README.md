# Proyecto Base de Datos ClassicModels – Sistema de Vistas Analíticas

## 📘 Descripción General

Este proyecto implementa una base de datos relacional basada en el modelo **ClassicModels**, desplegada mediante **Docker Compose**.  
El objetivo principal es automatizar la creación de la base de datos y un conjunto de **vistas SQL** diseñadas para diferentes áreas de análisis y soporte dentro de una organización.

A través del uso de **MySQL** y **phpMyAdmin**, se facilita la gestión, consulta y análisis de datos, mientras que las **vistas** proporcionan una capa de **abstracción, seguridad y análisis empresarial**.

---

## 🧱 Estructura del Proyecto
```bash
database/
├── docker-compose.yaml
└── model/
├── classicmodels.sql
└── views.sql
```
### 🔹 `classicmodels.sql`

Contiene el esquema completo de la base de datos ClassicModels, incluyendo:

- Tablas principales (`customers`, `orders`, `employees`, `products`, `offices`, etc.)
- Relaciones entre entidades (claves foráneas)
- Datos iniciales de prueba

### 🔹 `views.sql`

Define todas las **vistas** analíticas utilizadas en el proyecto.  
Estas vistas permiten obtener información filtrada, resumida o combinada de múltiples tablas, simplificando el análisis de los datos.

### 🔹 `docker-compose.yaml`

Archivo de configuración que define y orquesta los servicios del entorno:

- **MySQL 8.0**: base de datos principal, donde se cargan los archivos `.sql` automáticamente.
- **phpMyAdmin 5.2**: interfaz web para administrar y consultar la base de datos.
- Volumen persistente (`db_data`) para mantener los datos.
- Montaje automático de scripts en `/docker-entrypoint-initdb.d` para inicializar la base de datos y las vistas en el primer arranque.

---

## 🐳 Despliegue con Docker Compose

El entorno se levanta ejecutando:

```bash
docker compose up -d
```

## 1️⃣ Vista_Contactos_Soporte

Propósito: proveer al equipo de soporte solo los datos de contacto de los clientes, sin exponer información sensible.

Datos: nombre de la empresa, nombre completo del contacto, teléfono y ubicación (ciudad y país).

Beneficio: seguridad y simplicidad al ocultar información financiera innecesaria.

## 2️⃣ Vista_Pedidos_Pendientes

Propósito: identificar productos o pedidos que aún no han sido enviados.

Datos: número de pedido, cliente, producto, cantidad y fecha requerida.

Beneficio: facilita el seguimiento logístico y la priorización de entregas.

## 3️⃣ Vista_Desempeno_Oficina

Propósito: medir el desempeño de cada oficina mediante su cantidad de empleados y el total de ventas generadas.

Datos: ciudad, número de empleados, monto total de ventas.

Beneficio: análisis consolidado de rendimiento por ubicación.

## 4️⃣ Vista_Ventas_x_Empleado y Vista_Promedio_Oficina

Propósito: detectar oficinas con bajo rendimiento en relación al promedio global de ventas por empleado.

Estructura: vistas anidadas (una calcula ventas por empleado, otra promedia por oficina).

Beneficio: permite identificar sucursales con desempeño por debajo del estándar global.

## 5️⃣ Vista_Stock_Critico y Vista_Precios_Maximos

Propósito: listar productos con stock bajo y analizar cuáles pertenecen al segmento de precio más alto.

Estructura: vista anidada, donde una filtra por stock y la otra selecciona el precio máximo.

Beneficio: soporte para decisiones de reposición e inversión en productos de alto valor.

## 6️⃣ Vista_Max_x_Pedido y Vista_Max_x_Cliente

Propósito: analizar clientes con mayores gastos en productos individuales.

Estructura: vista de dos niveles: la primera calcula el monto máximo por pedido, la segunda obtiene el pedido más costoso por cliente.

Beneficio: segmentación de clientes de alto valor y análisis de consumo individual.
