--Punto 2			
CREATE VIEW datos_geom AS
SELECT *
FROM (SELECT *,
	  st_geohash(punto,6) gh6,  ST_SETSRID(ST_pointFromGeoHash (st_geohash(punto,6)),4326)  centroide_gh,
	ST_SETSRID(ST_geomFromGeoHash (st_geohash(punto,6)),4326) zona_gh
	 FROM (SELECT *, 
		   	ST_SetSRID(st_point((lat_lon->>'lon')::numeric, (lat_lon->>'lat')::numeric), 4326) ::geography punto
		  FROM sube_detA.datos_eco_gral_puey ) AS DP) AS DG
LEFT JOIN sube_detA.puntos_interes_gral_puey B
	ON ST_DWITHIN(punto, geom::geography, 500)
	
select *
from datos_geom;

--ver unos primeros datos 
SELECT *
FROM datos_geom
FETCH FIRST 10 ROWS ONLY;


--punto 3

select punto
from datos_geom
where (lat_lon->>'lon')::numeric <> 0 and (lat_lon->>'lat')::numeric <> 0


---punto 4
--elijo tres puntos y veo que la distancia entre ellos es mayor a 1200 metros
WITH datos as (
	SELECT 'SRID=4326;POINT( -57.64 -38.172)'::geography punto1, 'SRID=4326;POINT(-57.544 -37.926)'::geography punto2
	UNION ALL
	SELECT 'SRID=4326;POINT(-57.544 -37.926)'::geography punto1, 'SRID=4326;POINT( -57.834 -37.886 )'::geography punto2
	UNION ALL
	SELECT 'SRID=4326;POINT( -57.834 -37.886 )'::geography punto1, 'SRID=4326;POINT( -57.64 -38.172)'::geography punto2
)
SELECT ST_DISTANCE(punto1, punto2)
FROM DATOS
;

--Luego veo ninguno tiene distancia menor a 1200 metros con los puntos de interes
select distancia
from(
with datos as(
	select geom :: geography punto1,'SRID=4326;POINT(-57.834 -37.886 )'::geography punto2
	from datos_geom
	union all 
	select geom :: geography punto1,'SRID=4326;POINT(-57.544 -37.926)'::geography punto2
	from datos_geom
	union all 
	select geom :: geography punto1,'SRID=4326;POINT( -57.64 -38.172)'::geography punto2
	from datos_geom)
SELECT ST_DISTANCE(punto1, punto2) as distancia
FROM DATOS) as dist_datos
where distancia < 1200
;	
 
--Sumamos los puntos elegidos a la tabla de puntos de interes
INSERT INTO sube_detA.puntos_interes_gral_puey 
SELECT 'ESCUELA DE VUELO' lugar, ST_SetSRID(ST_POINT(-57.834, -37.886), 4326 ) geom
UNION ALL
SELECT 'ESCUELA MUNICIPAL' lugar, ST_SetSRID(ST_POINT(-57.544, -37.926), 4326 ) geom
UNION ALL
SELECT 'PLAYA PUBLICA' lugar, ST_SetSRID(ST_POINT( -57.64, -38.172), 4326 ) geom
;
--Vemos la tabla con los 15 puntos 
select *
from sube_detA.puntos_interes_gral_puey
;



--Punto 5

--Horas de mayor y menor demanda (las dos mayores y las tres menores):

--en todo el municipio
with datos_mm as(
with datos_d as (
	select hora, sum(cant_trx) demanda
	from datos_geom
	where hora between 6 and 20
	group by hora
	order by demanda desc)
select hora, demanda, 
	rank() over(order by demanda desc) as orden
from datos_d)
select hora, demanda
from datos_mm
where orden in (1,2,13,14,15);

--crecanos a los puntos de interes correspondientes
with datos_mm as(
with datos_d as (
select hora, sum(cant_trx) demanda
from datos_geom
where lugar in ('CASINO CENTRAL' , 'TERMINAL DE OMNIBUS' ,'FCEYN - UNMDP',
					'ESCUELA DE VUELO' ,'ESCUELA MUNICIPAL', 'PLAYA PUBLICA')
	 and hora between 6 and 20
group by hora
order by demanda desc)
select hora, demanda, 
	rank() over(order by demanda desc) as orden
from datos_d)
select hora, demanda
from datos_mm
where orden in (1,2,13,14,15);


--zonas de longitud 6

--i)

Select zona_gh , sum(cant_trx) cantidades
from datos_geom 
group by zona_gh
order by cantidades desc
fetch first 5 rows only
;

--discriminando el tipo de tarifa (ii)

with datos_max as(
	with dato_tarifas as(
		Select zona_gh ,tipo_tarifa , sum(cant_trx) cantidades
			from datos_geom
			group by zona_gh, tipo_tarifa 
			order by cantidades desc)
	select zona_gh, tipo_tarifa, cantidades, 
		rank() over (partition by tipo_tarifa order by cantidades desc) as orden
	from dato_tarifas)
select zona_gh, tipo_tarifa, cantidades
from datos_max
where orden in (1,2,3,4,5);


--separando horas especificas (iii)
with datos_max as(
	with dato_horas as(
		Select zona_gh, hora , sum(cant_trx) cantidades
		from datos_geom 
		where hora in (7,12,17)
		group by zona_gh , hora
		order by cantidades desc)
	select zona_gh, hora, cantidades, 
		rank() over (partition by hora order by cantidades desc) as orden
	from dato_horas)
select zona_gh, hora, cantidades
from datos_max
where orden in (1,2,3,4,5);


--mayor cantidad de lineas (iv)

Select zona_gh , count(distinct(linea)) cant_lineas
from datos_geom
group by zona_gh
order by cant_lineas desc
fetch first 5 rows only
;

--zona con una zona linea (v)
with zonas_chicas as(
	Select zona_gh , count(distinct(linea)) cant_lineas
	from datos_geom
	group by zona_gh)
select zona_gh
from zonas_chicas
where cant_lineas = '1'
;

--zonas de mayor y menor cantidad de lineas (vi)

select zona_gh , hora, linea, sum(cant_trx) cant_pasajeros
from datos_geom
where linea in ( select linea 
			   			from (Select linea, sum(cant_trx) cant_pasajeros
								from datos_geom
								group by distinct(linea)
								order by cant_pasajeros desc
								fetch first 1 rows only) as linea_max
			   union all
			   select linea 
			   			from (Select linea, sum(cant_trx) cant_pasajeros
								from datos_geom
								group by distinct(linea)
								order by cant_pasajeros asc
								fetch first 1 rows only) as linea_min)
group by zona_gh , hora, linea
order by linea, sum(cant_trx) desc

--lineas en los puntos de interes (viii)

select linea, lugar
from datos_geom
where linea in (select linea
					from datos_geom
					where lugar not in ('ESCUELA DE VUELO','ESCUELA MUNICIPAL','PLAYA PUBLICA')
					group by linea
					order by count(distinct lugar)desc
					fetch first 1 rows only)
	and lugar is not null
group by linea,lugar

		



