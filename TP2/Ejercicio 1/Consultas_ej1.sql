#1 ¿Qué socios tienen barcos amarrados en un número de amarre mayor que 10?
SELECT s.nombre,b.numero_amarre from Socios as s,barcos as b where s.id_socio=b.id_socio and b.numero_amarre>10;
#2 ¿Cuáles son los nombres de los barcos y sus cuotas de aquellos barcos cuyo socio se llama 'Juan Pérez'?
SELECT nombre as nombre_barco, cuota from barcos where id_socio in (select id_socio from socios where nombre='Juan Pérez');
#3 ¿Cuántas salidas ha realizado el barco con matrícula 'ABC123'?
SELECT COUNT(*) as cantidad_salida from salidas where matricula='ABC123';
#4 Lista los barcos que tienen una cuota mayor a 500 y sus respectivos socios.
SELECT s.id_socio, s.nombre , b.cuota  from socios as s, barcos as b where s.id_socio=b.id_socio and b.cuota>500 ORDER BY s.id_socio asc;
#5 ¿Qué barcos han salido con destino a 'Mallorca'?
SELECT nombre from barcos where matricula in (select matricula from salidas where destino='Mallorca');
#6 ¿Qué patrones (nombre y dirección) han llevado un barco cuyo socio vive en 'Barcelona'?
SELECT patron_nombre, patron_direccion from salidas where matricula in (select matricula from barcos where id_socio in (select id_socio from socios where direccion like '%Barcelona%'));

#EJERCICIOS CON JOIN

#1 ¿Qué socios tienen barcos amarrados en un número de amarre mayor que 10?
SELECT s.nombre,b.numero_amarre from socios as s  inner join barcos as b on s.id_socio=b.id_socio where b.numero_amarre>10;
#2 ¿Cuáles son los nombres de los barcos y sus cuotas de aquellos barcos cuyo socio se llama 'Juan Pérez'?
SELECT s.nombre,b.cuota from socios as s inner join barcos as b on s.id_socio=b.id_socio where s.nombre= 'Juan Pérez';
#3 ¿Cuántas salidas ha realizado el barco con matrícula 'ABC123'?
SELECT COUNT(*) as cantidad_salida from salidas as s inner join barcos as b on s.matricula=b.matricula where b.matricula='ABC123';
#4 Lista los barcos que tienen una cuota mayor a 500 y sus respectivos socios.
SELECT s.nombre, b.cuota from socios as s  inner join barcos as b on s.id_socio=b.id_socio where b.cuota>500 ORDER BY b.cuota desc;
#5 ¿Qué barcos han salido con destino a 'Mallorca'?
SELECT b.nombre from barcos as b inner join salidas as s on b.matricula=s.matricula where s.destino = 'Mallorca';
#6 ¿Qué patrones (nombre y dirección) han llevado un barco cuyo socio vive en 'Barcelona'?
SELECT s.patron_nombre, s.patron_direccion from salidas as s inner join barcos as b on s.matricula=b.matricula inner join socios as so on b.id_socio=so.id_socio where so.direccion like '%Barcelona%';
