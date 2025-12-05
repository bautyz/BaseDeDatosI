import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Telcosur#12",
    database="biblioteca"
)

cursor = conn.cursor(dictionary = True)

def menu():
    print("\n=== MENU BIBLIOTECA ===")
    print("1. Agregar usuario")
    print("2. Ver usuario")
    print("3. Actualizar usuario")
    print("4. Eliminar usuario")
    print("5. Agregar libro")
    print("6. Buscar libros")
    print("7. Calcular multa de un préstamo")
    print("8. Ver reporte de morosos")
    print("9. Modificar cuota")
    print("0. Salir")

def agregar_usuario():
    nombre = input("Nombre: ")
    email = input("Email: ")
    dni = input("DNI: ")
    tel = input("Teléfono: ")
    fecha = input("Fecha alta (YYYY-MM-DD): ")

    cursor.callproc("sp_crear_socio", [nombre, email, dni, tel, fecha])
    conn.commit()
    print("Usuario agregado.")

def ver_usuario():
    user_id = int(input("Ingrese ID: "))
    cursor.callproc("sp_ver_socio", [user_id])

    for result in cursor.stored_results():
        print(result.fetchall())

def actualizar_usuario():
    user_id = int(input("ID del usuario: "))
    nombre = input("Nuevo nombre: ")
    email = input("Nuevo email: ")
    tel = input("Nuevo teléfono: ")

    cursor.callproc("sp_actualizar_socio", [user_id, nombre, email, tel])
    conn.commit()
    print("Actualizado correctamente.")

def eliminar_usuario():
    user_id = int(input("ID a eliminar: "))
    cursor.callproc("sp_eliminar_socio", [user_id])
    conn.commit()
    print("Usuario eliminado.")

def agregar_libro():
    titulo = input("Título: ")
    autor = input("Autor: ")
    isbn = input("ISBN: ")
    total = int(input("Ejemplares totales: "))

    cursor.callproc("sp_crear_libro", [titulo, autor, isbn, total])
    conn.commit()
    print("Libro agregado.")

def buscar_libros():
    texto = input("Buscar: ")
    cursor.callproc("sp_buscar_libro", [texto])

    for result in cursor.stored_results():
        print(result.fetchall())

def calcular_multa():
    prestamo_id = int(input("ID del préstamo: "))

    args = [prestamo_id, 0, ""]
    result = cursor.callproc("sp_devolver_libro", args)

    print("Estado:", result[1])
    print("Mensaje:", result[2])

def ver_morosos():
    cursor.execute("SELECT * FROM vw_reporte_morosos")
    rows = cursor.fetchall()

    for r in rows:
        print(r)

def modificar_cuota():
    socio = int(input("ID socio: "))
    mes = int(input("Mes: "))
    anio = int(input("Año: "))
    monto = float(input("Nuevo monto: "))

    cursor.callproc("sp_modificar_cuota", [socio, mes, anio, monto])
    conn.commit()
    print("Cuota modificada.")

while True:
    menu()
    op = input("Seleccione opción: ")

    if op == "1":
        agregar_usuario()
    elif op == "2":
        ver_usuario()
    elif op == "3":
        actualizar_usuario()
    elif op == "4":
        eliminar_usuario()
    elif op == "5":
        agregar_libro()
    elif op == "6":
        buscar_libros()
    elif op == "7":
        calcular_multa()
    elif op == "8":
        ver_morosos()
    elif op == "9":
        modificar_cuota()
    elif op == "0":
        break
    else:
        print("Opción inválida.")
