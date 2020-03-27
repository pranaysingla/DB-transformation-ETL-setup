#orderitems
CREATE TABLE group1_stage.orderitems (
  id int(11) NOT NULL AUTO_INCREMENT,
  order_id int(11) unsigned DEFAULT NULL,
  product_id int(11) unsigned DEFAULT NULL,
  qty int(11) unsigned DEFAULT NULL,
  price decimal(12,2) DEFAULT NULL,
  created_at datetime DEFAULT NULL,
  updated_at datetime DEFAULT NULL,
  tax decimal(12,2) DEFAULT '0.00',
  total decimal(12,2) DEFAULT '0.00',
  discount decimal(12,2) DEFAULT '0.00',
  status int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  KEY orderitems_product_id (product_id),
  KEY orderitems_order_id (order_id),
  KEY orderitems_status (status)
); 
INSERT INTO group1_stage.orderitems (
id,
order_id,
product_id,
qty,
price,
created_at,
updated_at,
tax,
total,
discount,
status)
SELECT 
  id,
  order_id,
  product_id,
  qty,
  price,
  created_at,
  updated_at,
  tax,
  total,
  discount,
  status
FROM production.orderitems;

#orders
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `catalog_integration_id` int(11) unsigned DEFAULT NULL,
  `customer_id` int(11) unsigned DEFAULT NULL,
  `total` decimal(12,2) DEFAULT NULL,
  `tax` decimal(12,2) DEFAULT NULL,
  `order_date` datetime DEFAULT NULL,
  `data` json DEFAULT NULL,
  `status` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `catalog_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `orders_customer_id` (`customer_id`),
  KEY `orders_catalog_integration_id` (`catalog_integration_id`),
  KEY `orders_created_at` (`created_at`),
  KEY `orders_status` (`status`),
  KEY `orders_catalog_id` (`catalog_id`),
  KEY `idx_order_date` (`order_date`)
);

INSERT INTO group1_stage.orders (
id,
catalog_integration_id,
customer_id,
total,
tax,
order_date,
data,
status,
created_at,
updated_at,
catalog_id)
SELECT 
id,
catalog_integration_id,
customer_id,
total,
tax,
order_date,
data,
status,
created_at,
updated_at,
catalog_id
FROM production.orders;

#location_orderitem
CREATE TABLE `location_orderitem` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `store_id` varchar(255) DEFAULT NULL,
  `order_item_id` int(10) unsigned NOT NULL,
  `qty` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `location_orderitem_store_id` (`store_id`),
  KEY `location_orderitem_order_item_id` (`order_item_id`),
  KEY `location_orderitem_store_id_order_item_id` (`store_id`,`order_item_id`),
  KEY `location_orderitem_status` (`status`)
);
INSERT INTO group1_stage.location_orderitem (
id,
store_id,
order_item_id,
qty,
created_at,
status)
SELECT 
id,
store_id,
order_item_id,
qty,
created_at,
status
FROM production.location_orderitem;

#locations
CREATE TABLE `locations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `store_id` varchar(255) NOT NULL,
  `catalog_integration_id` int(11) unsigned DEFAULT NULL,
  `name` text,
  `city` varchar(255) NOT NULL,
  `state` varchar(255) NOT NULL,
  `zip` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `locations_catalog_integration_id` (`catalog_integration_id`)
);
INSERT INTO group1_stage.locations (
id,
store_id,
catalog_integration_id,
name,
city,
state,
zip)
SELECT 
id,
store_id,
catalog_integration_id,
name,
city,
state,
zip
FROM production.locations;

#catalog_integration
CREATE TABLE `catalog_integration` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `catalog_id` int(11) unsigned DEFAULT NULL,
  `integration_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `catalog_integration_catalog_id` (`catalog_id`),
  KEY `catalog_integration_integration_id` (`integration_id`)
);
INSERT INTO group1_stage.catalog_integration (
id,
catalog_id,
integration_id)
SELECT 
  id,
catalog_id,
integration_id
FROM production.catalog_integration;

#products
CREATE TABLE `products` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sku` varchar(255) NOT NULL,
  `catalog_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `brand` varchar(255) DEFAULT NULL,
  `price` decimal(12,4) DEFAULT NULL,
  `price_special` decimal(12,4) DEFAULT NULL,
  `catalog_integration_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `products_catalog_id` (`catalog_id`),
  KEY `products_sku` (`sku`),
  KEY `products_catalog_integration_id` (`catalog_integration_id`),
  KEY `products_catalog_id_catalog_integration_id` (`catalog_id`,`catalog_integration_id`),
  KEY `products_brand` (`brand`)
);

INSERT INTO group1_stage.products (
id,
sku,
catalog_id,
name,
brand,
price,
price_special,
catalog_integration_id
)
SELECT 
id,
sku,
catalog_id,
name,
brand,
price,
price_special,
catalog_integration_id
FROM production.products;


#returns
CREATE TABLE `returns` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int(11) unsigned DEFAULT NULL,
  `catalog_integration_id` int(11) unsigned DEFAULT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `data` json DEFAULT NULL,
  `returned_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `returns_order_id` (`order_id`)
);

INSERT INTO group1_stage.returns (
id,
order_id,
catalog_integration_id,
type,
data,
returned_at
)
SELECT 
id,
order_id,
catalog_integration_id,
type,
data,
returned_at
FROM production.returns;

#shipmentitems
CREATE TABLE `shipmentitems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shipment_id` int(11) unsigned DEFAULT NULL,
  `order_item_id` int(11) unsigned DEFAULT NULL,
  `qty` int(11) unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `shipmentitems_order_item_id` (`order_item_id`),
  KEY `shipmentitems_shipment_id` (`shipment_id`)
);

INSERT INTO group1_stage.shipmentitems (
id,
shipment_id,
order_item_id,
qty,
created_at,
updated_at
)
SELECT 
id,
shipment_id,
order_item_id,
qty,
created_at,
updated_at
FROM production.shipmentitems;

#admins
CREATE TABLE `admins` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `catalog_id` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `admins_id_index` (`id`),
  KEY `admins_catalog_id_index` (`catalog_id`)
);
INSERT INTO group1_stage.admins (
id,
catalog_id)
SELECT 
  id,
catalog_id
FROM production.admins;

#catalogs
CREATE TABLE `catalogs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `catalogs_id_index` (`id`)
);
INSERT INTO group1_stage.catalogs (
id)
SELECT 
  id
FROM production.catalogs;

#inventory
CREATE TABLE `inventory` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) unsigned DEFAULT NULL,
  `qty_on_hand` int(11) DEFAULT '0',
  `stock_status` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `inventory_product_id` (`product_id`),
  KEY `inventory_stock_status` (`stock_status`)
);
INSERT INTO group1_stage.inventory (
id,
product_id,
qty_on_hand,
stock_status)
SELECT 
  id,
product_id,
qty_on_hand,
stock_status
FROM production.inventory;

#productqueues
CREATE TABLE `productqueues` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `catalog_integration_id` int(11) unsigned DEFAULT NULL,
  `product_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `queues_catalog_integration_id` (`catalog_integration_id`),
  KEY `queues_product_id` (`product_id`),
  KEY `productqueues_catalog_integration_id` (`catalog_integration_id`),
  KEY `productqueues_product_id` (`product_id`)
);
INSERT INTO group1_stage.productqueues (
id,
catalog_integration_id,
product_id)
SELECT 
id,
catalog_integration_id,
product_id
FROM production.productqueues;

#shipments
CREATE TABLE `shipments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int(11) unsigned DEFAULT NULL,
  `data` json DEFAULT NULL,
  `shipment_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `shipments_order_id` (`order_id`)
);
INSERT INTO group1_stage.shipments (
id,
order_id,
data,
shipment_date
)
SELECT 
id,
order_id,
data,
shipment_date
FROM production.shipments;

#inventory_locations
CREATE TABLE `inventory_locations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `store_id` varchar(255) NOT NULL,
  `inventory_id` int(11) unsigned NOT NULL,
  `qty` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `inventory_locations_inventory_id` (`inventory_id`),
  KEY `inventory_locations_store_id` (`store_id`)
);
INSERT INTO group1_stage.inventory_locations (
id,
store_id,
inventory_id,
qty)
SELECT 
  id,
store_id,
inventory_id,
qty
FROM production.inventory_locations;

