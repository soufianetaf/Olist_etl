-- Fichier : sql/04_build_dwh.sql 

-- =====================================================================
-- 1. CLEANING : On supprime d'abord la table de faits, puis toutes les dimensions
-- =====================================================================
DROP TABLE IF EXISTS dwh.fact_orders;
DROP TABLE IF EXISTS dwh.dim_customers;
DROP TABLE IF EXISTS dwh.dim_products;
DROP TABLE IF EXISTS dwh.dim_date;

-- =====================================================================
-- 2. DDL : CRÉATION DES TABLES DIMENSIONS (Les parents)
-- =====================================================================

-- Table des clients
CREATE TABLE dwh.dim_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- Table des produits
CREATE TABLE dwh.dim_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,          
    product_description_lenght INT,  
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- Table des dates
CREATE TABLE dwh.dim_date (
    date_id INT PRIMARY KEY,                  
    full_date DATE NOT NULL,                  
    year INT NOT NULL,                        
    quarter INT NOT NULL,                     
    month INT NOT NULL,                       
    month_name VARCHAR(20) NOT NULL,          
    day INT NOT NULL,                         
    day_of_week INT NOT NULL,                 
    day_name VARCHAR(20) NOT NULL,            
    is_weekend BOOLEAN NOT NULL               
);

-- =====================================================================
-- 3. DDL : CRÉATION DE LA TABLE DE FAITS (L'enfant)
-- =====================================================================
CREATE TABLE dwh.fact_orders (
    order_id VARCHAR(50),
    order_item_id INT, -- Conservé en INT pour la cohérence avec Silver

    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    seller_id VARCHAR(50),

    order_purchase_timestamp_id INT,
    order_approved_at_id INT,
    order_delivered_customer_date_id INT,

    order_status VARCHAR(50),

    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),

    PRIMARY KEY(order_id, order_item_id),
    
    CONSTRAINT fk_customer 
        FOREIGN KEY(customer_id)
        REFERENCES dwh.dim_customers(customer_id),
    CONSTRAINT fk_product 
        FOREIGN KEY(product_id)
        REFERENCES dwh.dim_products(product_id),
    CONSTRAINT fk_purchase_date
        FOREIGN KEY(order_purchase_timestamp_id)
        REFERENCES dwh.dim_date(date_id),
    CONSTRAINT fk_approved_date 
        FOREIGN KEY(order_approved_at_id)
        REFERENCES dwh.dim_date(date_id),
    CONSTRAINT fk_delivered_date 
        FOREIGN KEY(order_delivered_customer_date_id)
        REFERENCES dwh.dim_date(date_id)
);

-- =====================================================================
-- 4. DML : ALIMENTATION DES TABLES (Remplissage Gold / DWH)
-- =====================================================================

-- Remplissage Clients
INSERT INTO dwh.dim_customers
SELECT 
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM silver.olist_customers;

-- Remplissage Produits
INSERT INTO dwh.dim_products 
SELECT 
    product_id,
    product_category_name,                   
    product_name_lenght,              
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM silver.olist_products;

-- Génération Automatique du Calendrier (2015 à 2019)
INSERT INTO dwh.dim_date
SELECT
    CAST(TO_CHAR(datum, 'YYYYMMDD') AS INT) AS date_id,
    datum AS full_date,
    EXTRACT(YEAR FROM datum) AS year,
    EXTRACT(QUARTER FROM datum) AS quarter,
    EXTRACT(MONTH FROM datum) AS month,
    TO_CHAR(datum, 'TMMonth') AS month_name,
    EXTRACT(DAY FROM datum) AS day,
    EXTRACT(ISODOW FROM datum) AS day_of_week, 
    TO_CHAR(datum, 'TMDay') AS day_name,
    CASE WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend
FROM generate_series('2015-01-01'::DATE, '2019-12-31'::DATE, '1 day'::INTERVAL) datum;

-- Remplissage de la Table de Faits 
INSERT INTO dwh.fact_orders
SELECT 
    i.order_id,
    i.order_item_id,
    o.customer_id,
    i.product_id,
    i.seller_id,
    CAST(TO_CHAR(o.order_purchase_timestamp, 'YYYYMMDD') AS INT),
    CAST(TO_CHAR(o.order_approved_at, 'YYYYMMDD') AS INT),
    CAST(TO_CHAR(o.order_delivered_customer_date, 'YYYYMMDD') AS INT),
    o.order_status, 
    i.price,
    i.freight_value
FROM silver.olist_order_items i
INNER JOIN silver.olist_orders o ON i.order_id = o.order_id;