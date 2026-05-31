-- Fichier : sql/02_create_raw_tables.sql

-- Supprimer les tables si elles existent déjà (pratique pour relancer le script)
DROP TABLE IF EXISTS raw.olist_customers;
DROP TABLE IF EXISTS raw.olist_orders;
DROP TABLE IF EXISTS raw.olist_order_items;
DROP TABLE IF EXISTS raw.olist_products;

-- 1. Table des clients
CREATE TABLE raw.olist_customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

-- 2. Table des commandes (Le cœur du modèle)
CREATE TABLE raw.olist_orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);

-- 3. Table des articles (Les détails de chaque commande)
CREATE TABLE raw.olist_order_items (
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price TEXT,
    freight_value TEXT
);

-- 4. Table des produits
CREATE TABLE raw.olist_products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght TEXT,          
    product_description_lenght TEXT,  
    product_photos_qty TEXT,
    product_weight_g TEXT,
    product_length_cm TEXT,
    product_height_cm TEXT,
    product_width_cm TEXT
);