# Resumen del Dominio

Sistema para gestionar una biblioteca: **socios (usuarios)**, **libros**, **préstamos** y **cuotas mensuales**. Debe manejar el préstamo y devolución de libros, el **cálculo de multas** según criterio (3% de la cuota mensual por cada día de atraso), consultas y reportes (**morosos**), y permitir la **modificación de cuotas** para mes/año.

---

## Entidades Fuertes y Relaciones

* **Entidades fuertes:** `socio`, `libro`, `prestamo`, `cuota`.
* **Relación:** `prestamo` relaciona `socio` y `libro`.
* **Observación:** la multa no necesita tabla propia; se calcula con función sobre la cuota y días de atraso.

---

## Atributos Principales

| Entidad | Atributos |
| :--- | :--- |
| `socio` | `(id, nombre, email, dni, telefono, fecha_alta)` |
| `libro` | `(id, titulo, autor, isbn, ejemplares_totales, ejemplares_disponibles)` |
| `prestamo` | `(id, socio_id, libro_id, fecha_prestamo, fecha_vencimiento, fecha_devolucion, estado)` |
| `cuota` | `(id, socio_id, mes, anio, monto, pagada, fecha_pago)` |

---

## Normalización

* **1NF:** todos los atributos atómicos. Teléfonos múltiples se normalizan conservando un solo teléfono; si se necesitan varios, crear tabla `telefono_socio`.
* **2NF:** cada tabla con PK simple y los atributos dependen totalmente de la PK.
* **3NF:** no hay dependencias transitivas (por ejemplo, datos de socio sólo en `socio`).

---

## Restricciones de Integridad

* **PK** en cada tabla.
* **FKs** con ON DELETE/ON UPDATE adecuadas:
    * `prestamo.socio_id` -> `socio.id` **ON DELETE CASCADE** (si se borra socio, borran sus préstamos históricos).
    * `prestamo.libro_id` -> `libro.id` **ON DELETE RESTRICT** (no permitir borrar libro con préstamos históricos).
    * `cuota.socio_id` -> `socio.id` **ON DELETE CASCADE**.
* **UNIQUE** en `socio.dni` y `libro.isbn`.
* **NOT NULL** en columnas esenciales.

---

## Índices

* `idx_libro_titulo` sobre `libro(titulo)` para búsquedas por título.
* `idx_socio_dni` sobre `socio(dni)`.
* `idx_prestamo_socio` sobre `prestamo(socio_id)`.

---

## Procedimientos y Funciones Principales

* `fn_calcular_multa(monto, dias)`: devuelve `multa = monto * 0.03 * dias`.
* `sp_prestar_libro(socio_id, libro_id, OUT ok, OUT msg)`: valida disponibilidad, inserta préstamo en transacción y disminuye `ejemplares_disponibles`.
* `sp_devolver_libro(prestamo_id, OUT ok, OUT msg)`: marca devolución, actualiza ejemplares, calcula multa si corresponde y la deja pendiente en cuota (o devuelve monto).
* `sp_modificar_cuota(socio_id, mes, anio, nuevo_monto)`: modifica cuota existente.

# Realizado por Nahuel Cappa - Legajo: 22903 - Proyecto N1.
