
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
