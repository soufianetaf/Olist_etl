#  Olist E-Commerce Data Warehouse : End-to-End ETL Pipeline

Ce projet implémente un pipeline ETL (Extract, Transform, Load) complet développé en **Python** et **PostgreSQL**. Il traite les données réelles de la marketplace brésilienne Olist (plus de 100 000 commandes) pour construire un Data Warehouse modélisé en schéma en étoile (Star Schema), prêt pour la Business Intelligence.

##  Sommaire

1. [À propos du projet](#1-à-propos-du-projet)
2. [Architecture des Données (Médaillon)](#2-architecture-des-données-médaillon)
3. [Structure du Projet](#3-structure-du-projet)
4. [Prérequis](#4-prérequis)
5. [Installation & Exécution (Guide Pas-à-Pas)](#5-installation--exécution-guide-pas-à-pas)
6. [Cas d'usage analytique](#6-cas-dusage-analytique)
7. [Auteur](#7-auteur)

---

## 1. À propos du projet

L'objectif de ce pipeline est d'extraire les données brutes fournies au format CSV, de les nettoyer en appliquant des règles strictes de qualité de données (gestion des valeurs nulles, nettoyage des caractères invisibles, typage SQL), puis de les charger dans un Data Warehouse optimisé pour l'analyse décisionnelle.

---

## 2. Architecture des Données (Médaillon)

Le pipeline est structuré en trois couches logiques au sein de PostgreSQL :

###  Couche RAW (Bronze)
Ingestion brute via la commande `COPY` de PostgreSQL. Toutes les données sont importées au format `TEXT` pour éviter les rejets silencieux lors de la lecture initiale des CSV.

###  Couche SILVER (Silver)
Phase de nettoyage, de transformation et de typage strict.
* **Cast des types :** `INT`, `NUMERIC`, `TIMESTAMP`.
* **Gestion des valeurs manquantes :** Utilisation de `COALESCE` (pour fournir des valeurs par défaut) et `NULLIF` (pour gérer les chaînes vides).
* **Nettoyage des chaînes :** Suppression des BOM (Byte Order Mark) et caractères invisibles via `TRIM` et `REPLACE`.
* **Sécurisation :** Mise en place des Clés Primaires (PK) et Clés Étrangères (FK).

###  Couche DWH (Gold)
Entrepôt de données modélisé en **Schéma en Étoile** pour la Business Intelligence.
* **Table de Faits (`fact_orders`) :** Centralise les métriques de ventes (`price`, `freight_value`), intègre des clés temporelles entières (`YYYYMMDD`), et inclut des *dimensions dégénérées* (`order_id`, `order_status`).
* **Tables de Dimensions :**
  * `dim_customers` : Informations sur les clients.
  * `dim_products` : Métadonnées sur les produits (catégories, dimensions).
  * `dim_date` : Table temporelle générée automatiquement pour les années 2015-2019, enrichie d'attributs analytiques (trimestre, nom du mois, week-end).

---

## 3. Structure du Projet

```text
├── data/                           # Fichiers sources CSV (à télécharger)
│   ├── olist_customers_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_orders_dataset.csv
│   └── olist_order_items_dataset.csv
├── sql/                            # Scripts SQL d'automatisation
│   ├── 01_init_schemas.sql         # Création des schémas raw, silver, dwh
│   ├── 02_create_raw_tables.sql    # DDL des tables brutes
│   ├── 03_transform_staging.sql    # Transfert et nettoyage (Raw -> Silver)
│   └── 04_build_dwh.sql            # Modélisation en étoile (Silver -> Gold)
├── src/                            # Code source Python
│   ├── utils/
│   │   └── db_connection.py        # Module de connexion sécurisée
│   ├── execute_sql.py              # Fonction d'exécution de fichiers SQL
│   ├── load_csv_to_raw.py          # Ingestion performante via psycopg2
│   └── main.py                     # Orchestrateur central du pipeline
├── .env.example                    # Template pour les variables d'environnement
├── requirements.txt                # Dépendances Python
└── README.md
```

---

## 4. Prérequis

* **Python 3.8+** installé sur votre machine.
* **PostgreSQL (12+)** installé et en cours d'exécution.
* Les fichiers CSV originaux du dataset Olist (à placer dans le dossier `data/`).

---

## 5. Installation & Exécution (Guide Pas-à-Pas)

Suivez ces instructions pour déployer le projet sur votre machine locale.

### Étape 1 : Cloner le dépôt et préparer l'environnement
Ouvrez votre terminal et exécutez les commandes suivantes :

```bash
# Cloner le projet
git clone [https://github.com/soufianetaf/Olist_etl.git](https://github.com/soufianetaf/Olist_etl.git)
cd olist-etl-pipeline

# Créer un environnement virtuel
python -m venv venv

# Activer l'environnement virtuel
# Sur Windows :
venv\Scripts\activate
# Sur Mac/Linux :
source venv/bin/activate

# Installer les dépendances requises
pip install -r requirements.txt
```

### Étape 2 : Configuration de la Base de Données

1. Ouvrez pgAdmin ou votre client SQL favori et créez une base de données vide (ex: `olist_db`).
2. À la racine du projet, créez un fichier nommé **`.env`** (basé sur `.env.example`).
3. Remplissez-le avec vos identifiants PostgreSQL locaux (sans espaces autour du `=`) :

```env
DB_NAME=olist_db
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe_secret
DB_HOST=localhost
```

> ⚠️ **Important :** Assurez-vous que le fichier `.env` est bien ajouté à votre fichier `.gitignore` afin de ne pas exposer vos identifiants publiquement sur GitHub.

### Étape 3 : Lancer le Pipeline ETL

Une fois l'environnement activé et la base de données configurée, lancez le script principal d'orchestration :

```bash
# Se placer dans le dossier source
cd src

# Exécuter le pipeline complet
python main.py
```

Le script affichera les logs d'exécution dans la console et effectuera l'extraction, la transformation, et le chargement de manière 100% automatisée.

---

## 6. Cas d'usage analytique

Une fois le script terminé, vous pouvez vous connecter à la base de données et interroger la table centrale `dwh.fact_orders` pour réaliser des analyses de Business Intelligence poussées :
* **Analyse Géographique :** Calculer le chiffre d'affaires par état ou ville (via `dim_customers`).
* **Analyse Produit :** Étudier l'impact de la longueur de la description ou du nombre de photos sur le volume de ventes (via `dim_products`).
* **Analyse Temporelle :** Observer la saisonnalité des commandes, les tendances par trimestre, ou comparer les ventes semaine vs week-end (via `dim_date`).

---

## 7. Auteur

**Soufiane Tafahi** - Data Engineer  
*Projet réalisé dans le cadre de la construction et l'optimisation de pipelines de données transactionnelles e-commerce.*