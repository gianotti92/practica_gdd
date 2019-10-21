use GD2015C1;

/*1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea
mayor o igual a $ 1000 ordenado por código de cliente.*/select clie_codigo, clie_razon_social from Clientewhere clie_limite_credito >= 1000order by clie_codigo;/*2. Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados
por cantidad vendida.*/select prod_codigo, prod_detalle from Productojoin Item_Factura on prod_codigo = item_productojoin Factura on fact_tipo = item_tipo and fact_sucursal = item_sucursal and fact_numero = item_numerowhere year (fact_fecha) = 2012group by prod_codigo, prod_detalle, item_cantidadorder by sum(item_cantidad); /* porque sum?*//*3. Realizar una consulta que muestre código de producto, nombre de producto y el
stock total, sin importar en que deposito se encuentre, los datos deben ser ordenados
por nombre del artículo de menor a mayor. */select prod_codigo, prod_detalle, isnull(sum(stoc_stock_maximo),0) as cantidad from Productoleft join STOCK on prod_codigo = stoc_productogroup by prod_codigo, prod_detalleorder by prod_detalle desc;

/*4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad
de artículos que lo componen. Mostrar solo aquellos artículos para los cuales el
stock promedio por depósito sea mayor a 100.*/

select prod_codigo, prod_detalle, isnull(sum(comp_cantidad),0) as cantidad from Producto
left join Composicion on prod_codigo = comp_producto
join STOCK on prod_codigo = stoc_producto
group by prod_codigo, prod_detalle
having isnull(avg(stoc_cantidad),0) > 100; /* preguntar como es el tema de por deposito y me viene null*/


/* 5 Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos
de stock que se realizaron para ese artículo en el año 2012 (egresan los productos
que fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el
2011. */

select prod_codigo, prod_detalle, isnull(sum(item_cantidad), 0) as egresos from Producto
left join Item_Factura on prod_codigo = item_producto
join Factura on item_tipo = fact_tipo and item_sucursal = fact_sucursal and item_numero = fact_numero
where year(fact_fecha) = 2012
group by prod_codigo, prod_detalle
having isnull(sum(item_cantidad), 0) 
>
(select isnull(sum(item_cantidad), 0) from Producto
left join Item_Factura on prod_codigo = item_producto
join Factura on item_tipo = fact_tipo and item_sucursal = fact_sucursal and item_numero = fact_numero
where year(fact_fecha) = 2011
group by prod_codigo, prod_detalle); /* como resuelvo la sub query */

/*6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de
ese rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos
artículos que tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’. */

select rubr_id, rubr_detalle, isnull(sum(stoc_cantidad), 0) as cantidad_de_articulos from Rubro
left join Producto on rubr_id = prod_rubro
join STOCK on stoc_producto = prod_codigo
join DEPOSITO on depo_codigo = stoc_deposito /*preguntar por este subquery que onda*/ 
where depo_codigo = '00' and stoc_cantidad > (select stoc_cantidad from STOCK where stoc_producto = '00000000') 
group by rubr_id, rubr_detalle;


/*7. Generar una consulta que muestre para cada articulo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio
= 10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que
posean stock. */
select prod_codigo, prod_detalle, max(item_precio) as minimo, min(item_precio) as maximo, case when MIN(prod_precio)=0 then 0 else(MAX(prod_precio)/ MIN(prod_precio)-1)*100 end diferencia_porcentual
from Producto
left join Item_Factura on prod_codigo = item_producto
join STOCK on prod_codigo = stoc_producto
group by prod_codigo, prod_detalle, stoc_cantidad
having isnull(stoc_cantidad, 0) > 0;


/* 9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados. */
select j.empl_codigo, e.empl_codigo, e.empl_nombre, count() from Empleado j 
join Empleado e on e.empl_codigo = j.empl_jefe;



/*10. Mostrar los 10 productos más vendidos en la historia y también los 10 productos
menos vendidos en la historia. Además mostrar de esos productos, quien fue el
cliente que mayor compra realizo.*/




/*11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos
tenga, solo se deberán mostrar las familias que tengan una venta superior a 20000
pesos para el año 2012.  creo que este esta bien =) */	

select fami_detalle, count(item_producto) as cant_vendida, sum((fa.fact_total - fa.fact_total_impuestos)) as valor_vendido from Familia f
join Producto p on prod_familia = fami_id
join Item_Factura i on i.item_producto = p.prod_codigo
join Factura fa on item_tipo = fact_tipo and item_sucursal = fact_sucursal and item_numero = fact_numero
where year (fact_fecha) = 2012
group by fami_detalle, p.prod_familia
having sum((fa.fact_total - fa.fact_total_impuestos)) > 20000
order by count(item_producto) desc
