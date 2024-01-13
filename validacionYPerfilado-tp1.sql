-- Validacion del cumplimiento de las especificaciones

--Formato de los datos
SELECT *
FROM sube_agreg.viajes_transp
FETCH FIRST 10 ROWS ONLY;

--cantidad de datos
select count(*) cantidad_total
from sube_agreg.viajes_transp;

--Cantidad total de datos por año, y en la misma consulta se puede observar si los años
--de los datos son los que se queria
select extract(year from dia), count(*) cantidad_total_año
from sube_agreg.viajes_transp
group by extract(year from dia);

--Veo que la cantidad total de dias por año sea correcta
select EXTRACT(YEAR FROM dia) anio, count(distinct dia) dias
from sube_agreg.viajes_transp
group by EXTRACT(YEAR FROM dia);

--Aca veo si esta columna solo tiene SI y NO
SELECT amba, count(*) cant
from sube_agreg.viajes_transp
group by amba; 

--Aca veo si esta columna solo tiene tipos validos de transporte
SELECT tipo_transporte, count(*) cant
from sube_agreg.viajes_transp
group by tipo_transporte; 

--Aca veo si esta columna solo tiene tipos validos de jurisdiccion
SELECT tipo_jurisdiccion, count(*) cant
from sube_agreg.viajes_transp
group by tipo_jurisdiccion; 

--Aca veo si esta columna solo tiene tipos validos de provincia
SELECT tipo_jurisdiccion, provincia
from sube_agreg.viajes_transp
group by tipo_jurisdiccion, provincia;


--Aca veo si esta columna solo tiene tipos validos de municipio
SELECT tipo_jurisdiccion, municipio
from sube_agreg.viajes_transp
group by tipo_jurisdiccion, municipio;


--Aca veo si existen provincias o municipios que sean el mismo y esten escrito diferente
SELECT DISTINCT provincia
From sube_agreg.viajes_transp;

SELECT DISTINCT municipio
From sube_agreg.viajes_transp;


--Aca veo si esta columna tiene valores negativos o cero (Se puede ver que si y no deberia)
SELECT cant_viajes
from sube_agreg.viajes_transp
WHERE cant_viajes <= 0 ;
 

--Consultas por campos vacios

SELECT *
FROM sube_agreg.viajes_transp
WHERE nombre_empresa  = '';

SELECT *
FROM sube_agreg.viajes_transp
WHERE linea = '';

SELECT *
FROM sube_agreg.viajes_transp
WHERE amba = '';

SELECT *
FROM sube_agreg.viajes_transp
WHERE tipo_transporte  = '';

SELECT *
FROM sube_agreg.viajes_transp
WHERE tipo_jurisdiccion  = '';

SELECT *
FROM sube_agreg.viajes_transp
WHERE provincia  = '';

SELECT *
FROM sube_agreg.viajes_transp
WHERE municipio  = '';

--Como hay vacio en provincia y municipio analizamos su relacion con el transporte


SELECT tipo_transporte, provincia
FROM sube_agreg.viajes_transp
WHERE provincia = ''
group by tipo_transporte , provincia;

SELECT tipo_transporte, municipio
FROM sube_agreg.viajes_transp
WHERE municipio = ''
group by tipo_transporte , municipio;


-- aca verifico que los vacios solo estan en un tipo de tranporte
SELECT tipo_transporte, tipo_jurisdiccion
FROM sube_agreg.viajes_transp
WHERE tipo_jurisdiccion = ''
group by tipo_transporte , tipo_jurisdiccion;

--verifico que todas las entradas de subte tengan vacios esos campos
SELECT tipo_transporte, municipio, provincia, tipo_jurisdiccion
FROM sube_agreg.viajes_transp
WHERE  tipo_transporte = 'SUBTE'
GROUP BY tipo_transporte, municipio, provincia, tipo_jurisdiccion;



--consulto por null
SELECT *
FROM sube_agreg.viajes_transp
WHERE dia  is null;

SELECT *
FROM sube_agreg.viajes_transp
WHERE nombre_empresa  is null;

SELECT *
FROM sube_agreg.viajes_transp
WHERE linea is null;

SELECT *
FROM sube_agreg.viajes_transp
WHERE amba is null;

SELECT *
FROM sube_agreg.viajes_transp
WHERE tipo_transporte is null;

SELECT *
FROM sube_agreg.viajes_transp
WHERE tipo_jurisdiccion is null;

SELECT *
FROM sube_agreg.viajes_transp
WHERE provincia  is null;

SELECT *
FROM sube_agreg.viajes_transp
WHERE municipio  is null;

SELECT *
FROM sube_agreg.viajes_transp
WHERE cant_viajes  is null;


--Perfilado

--Separando por linea y por año, cuento la cantidad de viajes totales
-- y observamos la minima cantidad de viajes por dia, la maxima, un promedio y cant de dias

select linea,EXTRACT(YEAR FROM dia) anio, sum(cant_viajes) total_viajes,
	min(cant_viajes) as min_xdia,
	max(cant_viajes) as max_xdia,
	avg(cant_viajes) as promedio,
	mode() within group (order by cant_viajes) moda,
	count(EXTRACT(YEAR FROM dia)) dias
from sube_agreg.viajes_transp
group by distinct(linea), EXTRACT(YEAR FROM dia)


--Diferenciando por linea y por año, las que realizaron menos de la mitad
-- de viajes por dia en el año.
Select linea, anio , cant_dias, total_viajes
from (SELECT linea, EXTRACT(YEAR FROM dia) anio, count(EXTRACT(YEAR FROM dia)) cant_dias, sum(cant_viajes) total_viajes
from sube_agreg.viajes_transp v
group by linea, EXTRACT(YEAR FROM dia))
where cant_dias <183;


--Analicemos la cantidad de empresas y la cant de lineas de cada una
select distinct(nombre_empresa), count(linea) cant_lineas
from sube_agreg.viajes_transp
group by distinct(nombre_empresa);

with lineas_empresas as (
	select distinct(nombre_empresa), count(linea) cant_lineas
	from sube_agreg.viajes_transp
	group by distinct(nombre_empresa))
select min(cant_lineas) minimo,
	max(cant_lineas) maximo,
	avg(cant_lineas) promedio,
	mode() within group (order by cant_lineas) moda
from lineas_empresas

with lineas_empresas as (
	select nombre_empresa, count(linea) cant_lineas
	from sube_agreg.viajes_transp
	group by nombre_empresa)
select nombre_empresa, cant_lineas
from lineas_empresas
where cant_lineas in (6,46597)
group by nombre_empresa,cant_lineas

--Ver la cantidad de viajes que se hace en cada tranporte
select tipo_transporte, sum(cant_viajes) viajes
from sube_agreg.viajes_transp
group by tipo_transporte
order by viajes desc;

--Contar un poco la cantidad en cada jurisdiccion
select tipo_transporte, tipo_jurisdiccion , sum(cant_viajes) viajes
from sube_agreg.viajes_transp
group by tipo_transporte, tipo_jurisdiccion
order by viajes desc;

--Del tipo colectivo ver cantidades en cada provincia
select provincia, sum(cant_viajes) viajes
from sube_agreg.viajes_transp
where tipo_transporte = 'COLECTIVO'
group by  provincia
order by viajes desc;



