#1 ¿Cuál es el nombre y la dirección de los procuradores que han trabajado en un asunto abierto?
SELECT p.nombre,p.direccion from procuradores as p inner join asuntos_procuradores as ap on p.id_procurador=ap.id_procurador inner join asuntos as a on a.numero_expediente=ap.numero_expediente where a.estado='Abierto';
#2 ¿Qué clientes han tenido asuntos en los que ha participado el procurador Carlos López?
select c.nombre,c.direccion from clientes as c inner join asuntos as a on c.dni=a.dni_cliente
inner join asuntos_procuradores as ap on a.numero_expediente=ap.numero_expediente
inner join procuradores as p on ap.id_procurador=p.id_procurador where p.nombre='Carlos López';
#3 ¿Cuántos asuntos ha gestionado cada procurador?
Select p.nombre, count(a.numero_expediente) as cantidad_asuntos from procuradores as p inner join asuntos_procuradores as ap on p.id_procurador=ap.id_procurador inner join asuntos as a on a.numero_expediente=ap.numero_expediente group by p.id_procurador;
#4 Lista los números de expediente y fechas de inicio de los asuntos de los clientes que viven en Buenos Aires.
SELECT c.nombre ,c.direccion, a.numero_expediente , a.fecha_inicio FROM asuntos as a INNER JOIN clientes as c ON a.dni_cliente = c.dni WHERE c.direccion LIKE '%Buenos Aires%';