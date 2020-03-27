----------------group1_final.dimension tables--------

--------order_dim--------
DROP TABLE group1_final.order_dim;
CREATE TABLE group1_final.order_dim (
order_key INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
catalog_id INT NOT NULL,
order_id int(11) NOT NULL,
order_date datetime DEFAULT NULL,
total decimal(12,2) DEFAULT NULL,
tax decimal(12,2) DEFAULT NULL,
shipment_charge decimal(12,2) DEFAULT NULL,
status varchar(255) DEFAULT NULL
);

INSERT INTO group1_final.order_dim (
catalog_id,
order_id,
order_date,
total,
tax,
shipment_charge,
status)
SELECT
ci.catalog_id,
o.id,
order_date,
total,
tax,
JSON_EXTRACT(data,'$."Shipping-Charge"') AS shipment_charge,
status 
FROM group1_stage.orders o
LEFT JOIN group1_stage.catalog_integration ci ON o.`catalog_integration_id`=ci.`id`;


--------store_dim--------
DROP TABLE group1_final.store_dim;
CREATE TABLE group1_final.store_dim ( 
store_key int(10) NOT NULL PRIMARY KEY AUTO_INCREMENT,
catalog_id INT NOT NULL,
store_id varchar(255) NOT NULL,
name text NOT NULL,
city varchar(255) NOT NULL default 'NA',
state varchar(255) NOT NULL default 'NA',
zip varchar(255) NOT NULL default 'NA') ;

INSERT INTO group1_final.store_dim (
catalog_id,
store_id,
name,
city,
state,
zip
)
SELECT
ci.catalog_id,
store_id,
name,
city,
state,
zip
FROM group1_stage.locations l
JOIN group1_stage.catalog_integration ci ON ci.id = l.catalog_integration_id;


--------orderitem_dim--------
CREATE TABLE group1_final.orderitem_dim ( 
orderitem_key int(10) NOT NULL PRIMARY KEY AUTO_INCREMENT,
orderitem_id INT NOT NULL,
order_id INT NOT NULL,
product_id INT NOT NULL) ;

INSERT INTO group1_final.orderitem_dim (
orderitem_id,
order_id,
product_id
)
SELECT
order_item_id,
order_id,
product_id
FROM group1_stage.orderitems;


--------product_dim--------
CREATE TABLE group1_final.product_dim (
product_key int(10) NOT NULL primary key auto_increment,
product_id int(11) NOT NULL,
catalog_integration_id int(11) NOT NULL,
name varchar(255) DEFAULT NULL,
brand varchar(255) DEFAULT NULL,
price decimal(12,4) DEFAULT NULL,
price_special decimal(12,4) DEFAULT NULL
);

INSERT INTO group1_final.product_dim(
product_id,
catalog_integration_id,
name,
brand,
price,
price_special
)
SELECT 
id,
catalog_integration_id,
name,
brand,
price,
price_special
FROM group1_stage.products;


--------shipment_dim--------
CREATE TABLE group1_final.shipment_dim (
  shipment_key INT AUTO_INCREMENT PRIMARY KEY,
  shipment_id INT,
  shipment_date DATETIME,
  shipment_rate DECIMAL(10,2))

INSERT INTO group1_final.shipment_dim (
shipment_id,
shipment_date,
shipment_rate)
SELECT 
id,
shipment_date,
CAST(json_extract(data, '$."rate_cost"') AS DECIMAL(10,2))
FROM group1_stage.shipments;


--------inventory_dim--------
CREATE OR REPLACE TABLE group1_final.inventory_dim (
inventory_key int(10) NOT NULL PRIMARY KEY AUTO_INCREMENT,
inventory_id int(11) NOT NULL,
qty_on_hand int(11) NOT NULL
);
INSERT INTO group1_final.inventory_dim (
inventory_id,
qty_on_hand
)
SELECT id, qty_on_hand 
FROM group1_stage.inventory;





----------------group1_final.fact tables----------------

--------order_fact--------
DROP TABLE group1_final.order_fact;
CREATE TABLE IF NOT EXISTS group1_final.order_fact (
  order_key INT NOT NULL,
  fulfillment_status INT NOT NULL,
  latest_shipment_date DATETIME DEFAULT NULL)


INSERT INTO group1_final.order_fact  (
  order_key,
  fulfillment_status,
  latest_shipment_date)
SELECT od.order_key,
 CASE WHEN count(*) = count(shipment_key) then 1 else 0 end as fulfillment_status,
 latest_shipment_date
FROM group1_final.order_dim od
LEFT JOIN group1_stage.orderitems oi ON od.order_id = oi.order_id
LEFT JOIN group1_stage.shipmentitems si ON oi.id = si.order_item_id
LEFT JOIN group1_final.shipment_dim shd ON si.shipment_id = shd.shipment_id
LEFT JOIN  (SELECT order_key,MAX(shipment_date) as latest_shipment_date
FROM order_item_fact oif JOIN shipment_dim sd ON oif.shipment_key = sd.shipment_key
GROUP BY 1) as a ON od.order_key = a.order_key
GROUP BY od.order_key；


--------order_item_fact--------
DROP TABLE group1_final.order_item_fact;
CREATE TABLE IF NOT EXISTS group1_final.order_item_fact(
  catalog_id INT NOT NULL,
  order_item_id INT NOT NULL,
  order_key INT NOT NULL,
  product_key INT NOT NULL,
  shipment_key INT,
  qty INT NOT NULL,
  store_key INT,
  inventory_key INT DEFAULT NULL)

INSERT INTO group1_final.order_item_fact(
catalog_id,
  order_item_id,
  order_key,
  product_key,
  shipment_key,
  qty,
  store_key,
  inventory_key)
SELECT od.catalog_id,
oi.id,
 od.order_key,
 pd.product_key,
 shd.shipment_key,
 oi.qty,
 sd.store_key, 
 id.inventory_key
FROM group1_stage.orderitems oi
JOIN group1_final.order_dim od ON oi.order_id = od.order_id
JOIN group1_final.product_dim pd ON oi.product_id = pd.product_id
LEFT JOIN group1_stage.shipmentitems si ON oi.id = si.order_item_id
LEFT JOIN group1_final.shipment_dim shd ON si.shipment_id = shd.shipment_id
JOIN group1_stage.location_orderitem loi ON oi.id = loi.order_item_id
JOIN group1_final.store_dim sd ON loi.store_id = sd.store_id AND sd.catalog_id = od.catalog_id
LEFT JOIN group1_final.inventory_dim id ON oi.product_id = id.inventory_id;


--------return_fact--------
CREATE TABLE IF NOT EXISTS group1_final.return_fact (
	`order_id` int(11) unsigned NOT NULL,
    `catalog_id` int(11) unsigned DEFAULT NULL,
    `type` int(11) NOT NULL DEFAULT '0',
    `order_item_id` int(11) unsigned DEFAULT NULL,
    `store_id` int(10) unsigned DEFAULT NULL,
	`qty` int(10) unsigned DEFAULT NULL,
	`price` decimal(12,2) DEFAULT NULL,
    `returned_at` datetime DEFAULT NULL
    );
    
INSERT into group1_final.return_fact(
order_id,
catalog_id,
type,
order_item_id,
store_id,
qty,
price,
returned_at
)
SELECT
ret.order_id,
ci.catalog_id,
ret.type,
ret.order_item_id,
ret.store_id,
ret.qty,
oi.price,
ret.returned_at
from group1_stage.returns ret
JOIN group1_stage.catalog_integration ci ON ret.catalog_integration_id = ci.id
JOIN group1_stage.orderitems oi ON ret.order_item_id = oi.id AND ret.order_id = oi.order_id;
