-- Fichier : sql/03_transform_staging.sql (Partie 1 : DDL)

-- 1. DROP : On supprime d'abord les enfants, puis les parents
DROP TABLE IF EXISTS silver.olist_order_items;
DROP TABLE IF EXISTS silver.olist_orders;
DROP TABLE IF EXISTS silver.olist_products;
DROP TABLE IF EXISTS silver.olist_customers;

-- 2. CREATE : On crée d'abord les parents (Customers et Products)

-- Table des clients
CREATE TABLE silver.olist_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- Table des produits
CREATE TABLE silver.olist_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,          
    product_description_lenght INT,  -- C'est une longueur, donc un entier
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- 3. CREATE : On crée les enfants (Orders, puis Order_Items)

-- Table des commandes
CREATE TABLE silver.olist_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,     
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    CONSTRAINT fk_orders_customers
       FOREIGN KEY(customer_id)
       REFERENCES silver.olist_customers(customer_id)
);

-- Table des articles
CREATE TABLE silver.olist_order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),             
    freight_value NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id), -- Clé composée
    CONSTRAINT fk_items_products
       FOREIGN KEY(product_id)
       REFERENCES silver.olist_products(product_id),
    CONSTRAINT fk_items_orders
       FOREIGN KEY(order_id)
       REFERENCES silver.olist_orders(order_id)
);



-- 5. Nettoyage et insertion des Clients
INSERT INTO silver.olist_customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
SELECT 
    customer_id,
    customer_unique_id,
    CAST(customer_zip_code_prefix AS INT),
    customer_city,
    customer_state
FROM raw.olist_customers;
-- 6. Nettoyage et insertion des Commandes (Gestion des Dates !)
INSERT INTO silver.olist_orders 
SELECT 
    order_id,
    customer_id,
    order_status,
    -- NULLIF('' , '') transforme une chaîne de texte vide de notre CSV en un vrai NULL SQL
    CAST(NULLIF(order_purchase_timestamp, '') AS TIMESTAMP),
    CAST(NULLIF(order_approved_at, '') AS TIMESTAMP),
    CAST(NULLIF(order_delivered_carrier_date, '') AS TIMESTAMP),
    CAST(NULLIF(order_delivered_customer_date, '') AS TIMESTAMP),
    CAST(NULLIF(order_estimated_delivery_date, '') AS TIMESTAMP)
FROM raw.olist_orders;

-- 7. Nettoyage et insertion des Produits (Gestion des NULLs !)
INSERT INTO silver.olist_products 
SELECT 
    product_id,
    COALESCE(product_category_name, 'Unknown'),                   -- Remplace NULL par 'Unknown'
    CAST(COALESCE(product_name_lenght, '0') AS INT),              -- Remplace NULL par 0
    CAST(COALESCE(product_description_lenght, '0') AS INT),
    CAST(COALESCE(product_photos_qty, '0') AS INT),
    CAST(COALESCE(product_weight_g, '0') AS INT),
    CAST(COALESCE(product_length_cm, '0') AS INT),
    CAST(COALESCE(product_height_cm, '0') AS INT),
    CAST(COALESCE(product_width_cm, '0') AS INT)
FROM raw.olist_products;



-- 8. Nettoyage et insertion des Articles commandés
INSERT INTO silver.olist_order_items 
SELECT 
    order_id,
    CAST(order_item_id AS INT),
    product_id,
    seller_id,
    CAST(NULLIF(shipping_limit_date, '') AS TIMESTAMP),
    CAST(price AS NUMERIC(10,2)),
    CAST(freight_value AS NUMERIC(10,2))
FROM raw.olist_order_items;