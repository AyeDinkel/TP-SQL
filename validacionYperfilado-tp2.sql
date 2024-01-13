--Tabla de puntos de interes:

select *
from sube_detA.puntos_interes_gral_puey;

--tabla puntos de interes que contiene 12 puntos
select count(*)
from sube_detA.puntos_interes_gral_puey;

--verificar existencia de nulos o vacios
select distinct lugar, geom
from sube_detA.puntos_interes_gral_puey
where lugar is null or trim(lugar)='';

select distinct lugar, geom
from sube_detA.puntos_interes_gral_puey
where geom is null or trim(geom)='';

--ver que los puntos son distintos 
select count(distinct geom)
from sube_detA.puntos_interes_gral_puey;


--Tabla datos gral puey:

--Formato de los datos
SELECT *
FROM sube_detA.datos_eco_gral_puey
FETCH FIRST 10 ROWS ONLY;

--cantidad de datos
select count(*) cantidad_total
from sube_detA.datos_eco_gral_puey;

--tabla datos, ver que son todos de un solo dia
select count(distinct dia)
from sube_detA.datos_eco_gral_puey;

--verificar existencia de nulos o vacios
select distinct empresa,linea,lat_lon,tipo_tarifa,cant_trx
from sube_detA.datos_eco_gral_puey
where empresa is null or trim(empresa)='';

select distinct empresa,linea,lat_lon,tipo_tarifa,cant_trx
from sube_detA.datos_eco_gral_puey
where linea is null or trim(linea)='';

select distinct empresa,linea,lat_lon,tipo_tarifa,cant_trx
from sube_detA.datos_eco_gral_puey
where tipo_tarifa is null or trim(tipo_tarifa)='';

select distinct empresa,linea,lat_lon,tipo_tarifa,cant_trx
from sube_detA.datos_eco_gral_puey
where dia is null;

select distinct empresa,linea,lat_lon,tipo_tarifa,cant_trx
from sube_detA.datos_eco_gral_puey
where hora is null;

select distinct empresa,linea,lat_lon,tipo_tarifa,cant_trx
from sube_detA.datos_eco_gral_puey
where lat_lon is null;

select distinct empresa,linea,lat_lon,tipo_tarifa,cant_trx
from sube_detA.datos_eco_gral_puey
where cant_trx is null;

--veo que no hay valores de horas fuera del rango correcto
select empresa,linea,lat_lon,tipo_tarifa,cant_trx
from sube_detA.datos_eco_gral_puey
where hora < 0 or hora > 23;

select distinct empresa,linea,lat_lon,tipo_tarifa,cant_trx
from sube_detA.datos_eco_gral_puey

--verificar que solo posee los dos valores posibles
select distinct tipo_tarifa
from sube_detA.datos_eco_gral_puey

--verificar que no existen valores en cant son negativos o cero
select cant_trx
from sube_detA.datos_eco_gral_puey
where cant_trx <=0

--buscar maximo y minimo de cant_trx por hora, empresa y linea
select hora,empresa, linea,
	min(cant_trx) min_cant,
	max(cant_trx) max_cant
from sube_detA.datos_eco_gral_puey
group by hora, empresa, linea

--solo por hora y empresa
select hora,empresa, 
	min(cant_trx) min_cant,
	max(cant_trx) max_cant
from sube_detA.datos_eco_gral_puey
group by hora, empresa





