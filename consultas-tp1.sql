-- CONSULTAS

--Ejercicio 3
--A)

CREATE VIEW viajes AS
SELECT * , EXTRACT(YEAR FROM dia) anio, TO_CHAR(dia, 'DAY') dia_semana
FROM sube_agreg.viajes_transp

select * 
from viajes

--3B) CUBE realiza todas las combinaciones posibles entre los atributos señalados

SELECT anio, tipo_jurisdiccion , amba, tipo_transporte ,sum(cant_viajes) viajes,COUNT(DISTINCT(linea)) lineas
FROM viajes
GROUP BY CUBE (anio, tipo_jurisdiccion , amba, tipo_transporte);

--3C)Mediciones estadisticas, aca se tiene en cuenta datos validos de cant_viajes, es decir aquellos que son mayores a cero

-- 1- Con todos los datos

SELECT total_viajes,promedio,minimo,maximo,sd,mediana,Q1,Q3,
	(Q1 - 1.5* (Q3-Q1)) lim_inf,
	(Q3 + 1.5* (Q3-Q1)) lim_sup
	FROM ( SELECT sum(cant_viajes) total_viajes,
	AVG(cant_viajes) promedio,
	MIN(cant_viajes) minimo,
	MAX(cant_viajes) maximo,
	STDDEV(cant_viajes) sd,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cant_viajes) mediana,
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cant_viajes) Q1,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cant_viajes) Q3
		FROM sube_agreg.viajes_transp);

--2

SELECT anio, amba ,total_viajes,promedio,minimo,maximo,sd,mediana,Q1,Q3,
	(Q1 - 1.5* (Q3-Q1)) lim_inf,
	(Q3 + 1.5* (Q3-Q1)) lim_sup
	FROM (SELECT  anio, amba,  sum(cant_viajes) total_viajes,
	AVG(cant_viajes) promedio,
	MIN(cant_viajes) minimo,
	MAX(cant_viajes) maximo,
	STDDEV(cant_viajes) sd,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cant_viajes) mediana,
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cant_viajes) Q1,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cant_viajes) Q3
		FROM viajes
		GROUP BY anio, amba);



--3

SELECT anio, amba , tipo_jurisdiccion, tipo_transporte, total_viajes,promedio,minimo,maximo,sd,mediana,Q1,Q3,
	(Q1 - 1.5* (Q3-Q1)) lim_inf,
	(Q3 + 1.5* (Q3-Q1)) lim_sup
	FROM (SELECT  anio, amba, tipo_jurisdiccion, tipo_transporte, sum(cant_viajes) total_viajes,
	AVG(cant_viajes) promedio,
	MIN(cant_viajes) minimo,
	MAX(cant_viajes) maximo,
	STDDEV(cant_viajes) sd,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cant_viajes) mediana,
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cant_viajes) Q1,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cant_viajes) Q3
		FROM viajes
		GROUP BY anio, amba,tipo_jurisdiccion, tipo_transporte);

--Ejercicio 5 

--Creamos una vista de la tabla con la que vamos a trabajar
create view viajes_amba as(
	SELECT anio, tipo_jurisdiccion , amba, tipo_transporte ,sum(cant_viajes) viajes,COUNT(DISTINCT(linea)) lineas
	FROM viajes
	GROUP BY CUBE (anio, tipo_jurisdiccion , amba, tipo_transporte));

--Primera observacion de la tabla
select *
from viajes_amba
FETCH FIRST 10 ROWS ONLY;

--1)
select *
from viajes_amba
where tipo_transporte is not null and anio is not null
	and amba is not null and tipo_jurisdiccion is not null;

--2)

select anio, tipo_transporte, sum(viajes) viajes_tot
from viajes_amba
group by anio, tipo_transporte
order by viajes_tot desc;

--3)

with viajes_sinNull as (
	select *
	from viajes_amba
	where tipo_transporte is not null and anio is not null
		and amba is not null and tipo_jurisdiccion is not null)
select tipo_jurisdiccion, tipo_transporte
from viajes_sinNull
group by tipo_jurisdiccion, tipo_transporte;

--4)

with viajes_sinNull as (
	select *
	from viajes_amba
	where tipo_transporte is not null and anio is not null
		and amba is not null and tipo_jurisdiccion is not null)
select tipo_transporte, amba, sum(viajes) viajes_tot
from viajes_sinNull
group by tipo_transporte, amba
order by viajes_tot desc;

--5)

with viajes_sinNull as (
	select *
	from viajes_amba
	where tipo_transporte is not null and anio is not null
		and amba is not null and tipo_jurisdiccion is not null)
select anio, tipo_jurisdiccion, sum(viajes) viajes_tot
from viajes_sinNull
group by anio, tipo_jurisdiccion
order by viajes_tot desc;

--6)

with viajes_sinNull as (
	select *
	from viajes_amba
	where tipo_transporte is not null and anio is not null
		and amba is not null and tipo_jurisdiccion is not null)
select  tipo_jurisdiccion, sum(lineas) cant_lineas
from viajes_sinNull
group by tipo_jurisdiccion
order by cant_lineas desc;


--7)

with viajes_sinNull as (
	select *
	from viajes_amba
	where tipo_transporte is not null and anio is not null
		and amba is not null and tipo_jurisdiccion is not null)
select  tipo_jurisdiccion,amba, sum(lineas) cant_lineas
from viajes_sinNull
group by tipo_jurisdiccion, amba
order by cant_lineas desc;

--8)

with viajes_sinNull as (
	select *
	from viajes_amba
	where tipo_transporte is not null and anio is not null
		and amba is not null and tipo_jurisdiccion is not null)
select  tipo_jurisdiccion, amba, sum(viajes) tot_viajes
from viajes_sinNull
group by tipo_jurisdiccion, amba
order by tot_viajes desc;

--9)

with viajes_sinNull as (
	select *
	from viajes_amba
	where tipo_transporte is not null and anio is not null
		and amba is not null and tipo_jurisdiccion is not null)
select  tipo_jurisdiccion, amba, sum(lineas) cant_lineas, sum(viajes) tot_viajes
from viajes_sinNull
group by tipo_jurisdiccion, amba
order by tot_viajes desc;



--10)

with viajes_sinNull as (
	select *
	from viajes_amba
	where tipo_transporte is not null and anio is not null
		and amba is not null and tipo_jurisdiccion is not null)
select  anio, sum(lineas) cant_lineas
from viajes_sinNull
group by anio;

with viajes_sinNull as (
	select *
	from viajes_amba
	where tipo_transporte is not null and anio is not null
		and amba is not null and tipo_jurisdiccion is not null)
select  anio,tipo_transporte, sum(lineas) cant_lineas
from viajes_sinNull
group by anio, tipo_transporte;


--Ejercicio 6)

--a

with rankeados as (
	select tipo_jurisdiccion, provincia, municipio , tipo_transporte,linea, 
		sum(cant_viajes) cant_viajes_linea, count(distinct dia) dia_de_act,
		rank() over (partition by tipo_jurisdiccion, provincia, municipio , tipo_transporte
					order by sum(cant_viajes) desc) orden
	from viajes
	where anio = '2022'
	group by linea,  tipo_transporte, tipo_jurisdiccion, provincia, municipio)
select tipo_jurisdiccion, provincia, municipio , tipo_transporte,linea, 
		 cant_viajes_linea, dia_de_act
from rankeados
where orden = 1 
order by cant_viajes_linea desc;


--b

with viajes_max as (
	with viajes_mes as(
		select linea, tipo_jurisdiccion, provincia, municipio, extract(month from dia) mes,anio, 
				sum(cant_viajes) viajes_mes,
				lag(extract(month from dia)) over (partition by linea, tipo_jurisdiccion, provincia, municipio
									order by extract(month from dia), anio) mes_ant,
			lag(anio) over (partition by linea, tipo_jurisdiccion, provincia, municipio
									order by extract(month from dia), anio) anio_mes_ant,
				lag(sum(cant_viajes)) over (partition by linea, tipo_jurisdiccion, provincia, municipio
									order by extract(month from dia)) viajes_mes_ant
		from viajes
		where amba='SI' and tipo_transporte='COLECTIVO'
		GROUP BY linea,mes, anio, tipo_jurisdiccion, provincia, municipio)
	select * , ((100*(viajes_mes-viajes_mes_ant))/viajes_mes_ant)  variacion_intermensual,
		(case when viajes_mes_ant is not null 
				then rank() over (partition by linea, tipo_jurisdiccion, provincia, municipio
						  order by abs(((100*(viajes_mes-viajes_mes_ant))/viajes_mes_ant)) desc)
								 end ) orden
	from viajes_mes)
select linea, tipo_jurisdiccion, provincia, municipio, anio, mes, viajes_mes, anio_mes_ant, mes_ant, viajes_mes_ant, variacion_intermensual
from viajes_max
where orden = 2 






	




