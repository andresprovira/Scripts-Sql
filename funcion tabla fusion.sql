SELECT c1.objectid as id_cable_origen,SPLIT_PART(SPLIT_PART(c1.FIBRAS_ACT,',',1),'-',1) as filamento_origen,
SPLIT_PART(SPLIT_PART(c2.FIBRAS_ACT,',',1),'-',1) as filamento_destino,c2.objectid as id_cable_destino, c1.codigo as cod_tramo_origen, c2.codigo as cod_tramo_destino, '' as splitter, t1.objectid_1 as id_objeto_origen, t2.objectid_1 as id_objeto_destino, t1.codigo as cod_objeto_origen, t2.codigo as id_objeto_destino
FROM cable c1, cable c2, telecom_premises t1, telecom_premises t2
WHERE c1.objectid=763 /*Tramo_origen*/
AND c2.objectid=764 /*Tramo_destino*/
AND t1.objectid_1=110 /*Objeto_origen*/
AND t2.objectid_1 =61 /*Objeto_destino*/


SELECT * FROM cable
/*Las últimas fibras siempre se conectan en las tp, las siguientes se fusionarian entre cable y cable, así con todo, Importante a la hora de crear la lógica del bucle
ya que podría coger el último elemento del SPLIT solo para las tp y los siguientes para los cables*/

/*el número de registros en fibras_act separados por ',' me indican la cantidad de objetos tp que se encuentra en ese recorrido, en este caso serían 4 los tp que tiene que pasar
contando el último, y me indica el límite a la hora de realizar el loop */

/*FUNCIONES IMPORTANTES para la lógica string_to_array sacar las fibras en un array y array_length para saber el tamaño del array*/

/*Explicación función:

Es una función que recibe 4 parámetros, en este caso necesitamos cable origen, cable destino, tp_origen, tp_destino, sus ids para encontrar los objetos*/

CREATE OR REPLACE FUNCTION fusion_cable_tp(cable_origen numeric, cable_destino numeric, tp_origen numeric, tp_destino numeric)

RETURNS TABLE(
	id_cable_origen numeric,
	filamento_origen text,
	filamento_destino text,
	id_cable_destino numeric,
	cod_tramo_origen VARCHAR,
	cod_tramo_destino VARCHAR,
	splitter VARCHAR,
	id_objeto_origen numeric,
	id_objecto_destino numeric,
	cod_objeto_origen VARCHAR,	
	cod_objeto_destino VARCHAR
	

) AS $$

DECLARE
/*Declaramos las variables que necesitamos*/
splitter VARCHAR;
filamento_origen text;
filamento_destino text;
fibras_act1 text []; 
fibras_act2 text []; 
fibras_res1 text [];
fibras_res2 text []; 
cont integer; /*La variable cont realmente no es necesario, la uso para determinar el primer elemento o segundo del split segun '-'. Con poner 1 o 2 sería suficiente*/

BEGIN
splitter = '';
cont=1; 
/*Obtenemos tanto las fibras act como las fibras res como arrays de fibras*/
SELECT string_to_array(c.FIBRAS_ACT,',') into fibras_act1 FROM cable c WHERE objectid=cable_origen; 
SELECT string_to_array(c.FIBRAS_ACT,',') into fibras_act2 FROM cable c WHERE objectid=cable_destino;
SELECT string_to_array(c.FIBRAS_RES,',') into fibras_res1 FROM cable c WHERE objectid=cable_origen;
SELECT string_to_array(c.FIBRAS_RES,',') into fibras_res2 FROM cable c WHERE objectid=cable_destino;



/*Realizamos un bucle for, hasta que llegue al tamaño del array de las fibras del cable_origen*/
for counter in 1..array_length(fibras_act1,1) by 1
LOOP


IF(counter = array_length(fibras_act1,1)) /*En el caso de que sea el último elemento nos indicará que son las fibras que entran en las cto, en la primera query sera div1 y en la segunda div2*/
	THEN splitter='div1';
	END IF;

/*Activas*/
RETURN QUERY
SELECT c1.objectid as id_cable_origen,SPLIT_PART(fibras_act1[counter],'-',cont), SPLIT_PART(fibras_act2[counter],'-',cont),c2.objectid as id_cable_destino, c1.codigo as cod_tramo_origen, c2.codigo as cod_tramo_destino, splitter, t1.objectid_1 as id_objeto_origen, t2.objectid_1 as id_objeto_destino, t1.codigo as cod_objeto_origen, t2.codigo as id_objeto_destino
FROM cable c1, cable c2, telecom_premises t1, telecom_premises t2
WHERE c1.objectid=cable_origen  /*Tramo_origen*/
AND c2.objectid=cable_destino /*Tramo_destino*/
AND t1.objectid_1=tp_origen  /*Objeto_origen*/
AND t2.objectid_1 =tp_destino /*Objeto_destino*/
;


IF(counter = array_length(fibras_act1,1))
	THEN splitter='div2';
	END IF;
	
RETURN QUERY
SELECT c1.objectid as id_cable_origen,SPLIT_PART(fibras_act1[counter],'-',cont + 1), SPLIT_PART(fibras_act2[counter],'-',cont + 1),c2.objectid as id_cable_destino, c1.codigo as cod_tramo_origen, c2.codigo as cod_tramo_destino, splitter, t1.objectid_1 as id_objeto_origen, t2.objectid_1 as id_objeto_destino, t1.codigo as cod_objeto_origen, t2.codigo as id_objeto_destino
FROM cable c1, cable c2, telecom_premises t1, telecom_premises t2
WHERE c1.objectid=cable_origen  /*Tramo_origen*/
AND c2.objectid=cable_destino /*Tramo_destino*/
AND t1.objectid_1=tp_origen  /*Objeto_origen*/
AND t2.objectid_1 =tp_destino /*Objeto_destino*/
;


/*Reservas*/
splitter=''; /*estas son las reservas las cuales las últimas se dejarán en dicho splitter*/
RETURN QUERY
SELECT c1.objectid as id_cable_origen,SPLIT_PART(fibras_res1[counter],'-',cont), SPLIT_PART(fibras_res2[counter],'-',cont),c2.objectid as id_cable_destino, c1.codigo as cod_tramo_origen, c2.codigo as cod_tramo_destino, splitter, t1.objectid_1 as id_objeto_origen, t2.objectid_1 as id_objeto_destino, t1.codigo as cod_objeto_origen, t2.codigo as id_objeto_destino
FROM cable c1, cable c2, telecom_premises t1, telecom_premises t2
WHERE c1.objectid=cable_origen  /*Tramo_origen*/
AND c2.objectid=cable_destino /*Tramo_destino*/
AND t1.objectid_1=tp_origen  /*Objeto_origen*/
AND t2.objectid_1 =tp_destino /*Objeto_destino*/
;


RETURN QUERY
SELECT c1.objectid as id_cable_origen,SPLIT_PART(fibras_res1[counter],'-',cont + 1), SPLIT_PART(fibras_res2[counter],'-',cont + 1),c2.objectid as id_cable_destino, c1.codigo as cod_tramo_origen, c2.codigo as cod_tramo_destino, splitter, t1.objectid_1 as id_objeto_origen, t2.objectid_1 as id_objeto_destino, t1.codigo as cod_objeto_origen, t2.codigo as id_objeto_destino
FROM cable c1, cable c2, telecom_premises t1, telecom_premises t2
WHERE c1.objectid=cable_origen  /*Tramo_origen*/
AND c2.objectid=cable_destino /*Tramo_destino*/
AND t1.objectid_1=tp_origen  /*Objeto_origen*/
AND t2.objectid_1 =tp_destino /*Objeto_destino*/
;




END LOOP;
END; $$ LANGUAGE plpgsql;

DROP FUNCTION fusion_cable_tp(numeric,numeric,numeric,numeric)

/*ejemplo de uso de inicio a fin*/
INSERT INTO tabla_fusion SELECT * from fusion_cable_tp(763,764,110,61)

SELECT * from fusion_cable_tp(764,765,61,59)

SELECT * from fusion_cable_tp(765,768,59,69)

SELECT * FROM fusion_tp_tp(768,69,111)

/*ejemplo de uso de fin a inicio*/

SELECT * from fusion_cable_tp(768,767,111,69)



/*FUNCION TP_CABLE_TP*/
/*Esta Función es similar a la anterior pero recibe solo 3 parámetros, ya que se realiza cuando el tp_destino es el final del recorrido*/
CREATE OR REPLACE FUNCTION fusion_tp_tp(cable_origen numeric, tp_origen numeric, tp_destino numeric)

RETURNS TABLE(
	id_cable_origen numeric,
	filamento_origen text,
	filamento_destino text,
	id_cable_destino integer,
	cod_tramo_origen VARCHAR,
	cod_tramo_destino VARCHAR,
	splitter VARCHAR,
	id_objeto_origen numeric,
	id_objecto_destino numeric,
	cod_objeto_origen VARCHAR,	
	cod_objeto_destino VARCHAR
	

) AS $$

DECLARE
splitter VARCHAR;
filamento_destino text;
cod_tramo_destino VARCHAR;

BEGIN

filamento_destino='';
splitter='div1';
cod_tramo_destino='';

RETURN QUERY
SELECT c1.objectid as id_cable_origen,SPLIT_PART(c1.fibras_act,'-',1),filamento_destino,0, c1.codigo as cod_tramo_origen,cod_tramo_destino, splitter, t1.objectid_1 as id_objeto_origen, t2.objectid_1 as id_objeto_destino, t1.codigo as cod_objeto_origen, t2.codigo as id_objeto_destino
FROM cable c1, telecom_premises t1, telecom_premises t2
WHERE c1.objectid=cable_origen  /*Tramo_origen*/
AND t1.objectid_1=tp_origen  /*Objeto_origen*/
AND t2.objectid_1 =tp_destino /*Objeto_destino*/
;

splitter='div2';

RETURN QUERY
SELECT c1.objectid as id_cable_origen,SPLIT_PART(c1.fibras_act,'-',2),filamento_destino,0, c1.codigo as cod_tramo_origen, cod_tramo_destino,splitter, t1.objectid_1 as id_objeto_origen, t2.objectid_1 as id_objeto_destino, t1.codigo as cod_objeto_origen, t2.codigo as id_objeto_destino
FROM cable c1, telecom_premises t1, telecom_premises t2
WHERE c1.objectid=cable_origen  /*Tramo_origen*/
AND t1.objectid_1=tp_origen  /*Objeto_origen*/
AND t2.objectid_1 =tp_destino /*Objeto_destino*/
;


/*Reservas*/
splitter=''; /*estas son las reservas las cuales las últimas se dejarán en dicho splitter*/
RETURN QUERY
SELECT c1.objectid as id_cable_origen,SPLIT_PART(c1.fibras_res,'-',1),filamento_destino,0, c1.codigo as cod_tramo_origen,cod_tramo_destino, splitter, t1.objectid_1 as id_objeto_origen, t2.objectid_1 as id_objeto_destino, t1.codigo as cod_objeto_origen, t2.codigo as id_objeto_destino
FROM cable c1, telecom_premises t1, telecom_premises t2
WHERE c1.objectid=cable_origen  /*Tramo_origen*/
AND t1.objectid_1=tp_origen  /*Objeto_origen*/
AND t2.objectid_1 =tp_destino /*Objeto_destino*/
;


RETURN QUERY
SELECT c1.objectid as id_cable_origen,SPLIT_PART(c1.fibras_res,'-',2),filamento_destino,0, c1.codigo as cod_tramo_origen,cod_tramo_destino, splitter, t1.objectid_1 as id_objeto_origen, t2.objectid_1 as id_objeto_destino, t1.codigo as cod_objeto_origen, t2.codigo as id_objeto_destino
FROM cable c1, telecom_premises t1, telecom_premises t2
WHERE c1.objectid=cable_origen  /*Tramo_origen*/
AND t1.objectid_1=tp_origen  /*Objeto_origen*/
AND t2.objectid_1 =tp_destino /*Objeto_destino*/
;



END; $$ LANGUAGE plpgsql;

DROP FUNCTION fusion_tp_tp(numeric,numeric,numeric)

SELECT * FROM fusion_tp_tp(777,110,114)

/*Pruebas para hacer la fusion de un recorrido completo*/
SELECT * from cable c
WHERE c.objectid=763

SELECT * FROM  telecom_premises tp
WHERE tp.objectid_1=111



/*Para realizar la funcion debería solo pedir el objectid del cable y la ciudad, en campo ciudad es para evitar ctos repetidas o cables repetidos*/

/*tp destino*/
SELECT * from telecom_premises tp
WHERE tp.codigo =(SELECT destino FROM  cable c
WHERE c.objectid=764) AND ciudad='VEGAS DE ALMENARA'

/*cable destino*/
SELECT * FROM cable c 
WHERE c.origen=(SELECT destino FROM  cable c
WHERE c.objectid=764) AND ciudad='VEGAS DE ALMENARA'
LIMIT 1


/*tp origen*/
SELECT *  FROM telecom_premises tp
WHERE tp.codigo= (SELECT origen FROM  cable c
WHERE c.objectid=764) AND ciudad='VEGAS DE ALMENARA'


/*FUNCION RECORRIDO CABLE*/
/*Ahora debemos usar esta función dentro del bucle del recorrido, y salir cuando el cable siguiente sea null*/

CREATE OR REPLACE FUNCTION recorridoCable(cable_origen numeric, city text)
RETURNS VOID AS $$ /*Duda sobre lo que devuelve esta funcion*/

DECLARE 
tp_origen numeric;
cable_destino numeric;
tp_destino numeric;

BEGIN
/*Le damos un valor inicial para que entre en el bucle*/
cable_destino=0;
/*El bucle se realiza hasta que no encuentre otro cable destino*/
while  (cable_destino IS NOT NULL) loop
/*obtemos tp_origen, tp_destino y cable_destino del cable apartir del cable que recibimos en una funcion*/
SELECT objectid_1 into tp_origen FROM telecom_premises tp WHERE tp.codigo= (SELECT origen FROM  cable c WHERE c.objectid=cable_origen) AND ciudad = city ;
SELECT objectid into cable_destino FROM cable c WHERE c.origen=(SELECT destino FROM  cable c WHERE c.objectid=cable_origen) AND ciudad=city LIMIT 1;
SELECT objectid_1 into tp_destino FROM telecom_premises tp WHERE tp.codigo =(SELECT destino FROM  cable c WHERE c.objectid=cable_origen) AND ciudad=city;

/*En el caso que nos encontremos al final del recorrido llamamos a la funcion que termina en un tp*/
if (cable_destino IS NULL)
THEN INSERT INTO tabla_fusion SELECT * FROM fusion_tp_tp(cable_origen,tp_origen,tp_destino);
/*sino realiza la función normal de fusión*/
else INSERT INTO tabla_fusion SELECT * from fusion_cable_tp(cable_origen,cable_destino,tp_origen, tp_destino);
end if;

/*Le asignamos la id del cable destino al cable origen para que se vuelva a hacer el bucle y sigue realizando las fusiones*/
cable_origen=cable_destino;

end loop;



END; $$ LANGUAGE plpgsql;

/*La idea de esta función es que llame a las otras dos funciones que realicé, las cuales devuelve una tabla con las fusiones realizadas entre cables y ctos
-Mi idea es que devuelva una tabla juntando el resultado de las tablas anteriores
-También podría modificar las funciones para que me realicen inserts en una tabla en vez de retornarme tablas*/

DROP FUNCTION recorridocable(numeric,text)

/*Al llamar esta funcion no me devuelve nada*/
SELECT recorridoCable(764,'VEGAS DE ALMENARA');
SELECT recorridoCable(777,'VEGAS DE ALMENARA');

DELETE FROM tabla_fusion;


SELECT objectid FROM cable c WHERE c.origen=(SELECT destino FROM  cable c WHERE c.objectid=768) AND ciudad='VEGAS DE ALMENARA' LIMIT 1;