import os
from utils.db_connection import get_connexion
from execute_sql import execute_sql
from load_csv_to_raw import load

# 1. Créer la connexion avec notre base de données
connexion = get_connexion()

def extract():
    """Phase 1 : Extraction et Chargement en zone Raw"""
    print("\n--- ÉTAPE 1 : INITIALISATION ---")
    # Création des schémas (raw, silver, dwh)
    execute_sql(connexion, "../sql/01_init_schemas.sql")
    
    # Création des tables brutes dans le schéma raw (ÉTAPE MANQUANTE AJOUTÉE)
    execute_sql(connexion, "../sql/02_create_raw_tables.sql")

    print("\n--- ÉTAPE 2 : CHARGEMENT DES CSV VERS RAW ---")
    # Insertion des fichiers CSV dans notre schéma raw (avec chemins relatifs !)
    load(connexion, "raw.olist_customers", "../data/olist_customers_dataset.csv")
    load(connexion, "raw.olist_products", "../data/olist_products_dataset.csv")
    load(connexion, "raw.olist_orders", "../data/olist_orders_dataset.csv")
    load(connexion, "raw.olist_order_items", "../data/olist_order_items_dataset.csv")

def transform():
    """
    Phase 2 : Transoformation : raw -> silver
    Transformer les types des donnes , manipuler les donnees manquantes et  les duplicates
    """
    print("Etape 3 : Début de la partie de la transformation (création + insertion)")
    #creation des tables de shema silver et fait les transformation
    execute_sql(connexion,"../sql/03_transform_staging.sql")

def load_dwh():
    """
    Phase 3 : charger les données dans notre dwh
    creer le schema en etoile et inserer les donnees depuis silver
    """

    print("Etape 04 : Début de la partie du chargement")
    execute_sql(connexion,"../sql/04_build_dwh.sql")

def orchestractor():
    """Le chef d'orchestre de notre ETL"""
    print(" Début de notre pipeline ETL...")
    
    # Si la connexion a échoué, on arrête tout
    if connexion is None:
        print(" Pipeline annulé : Impossible de se connecter à la base.")
        return

    # Lancement de la phase d'extraction
    extract()

    # Lancement de la phase de  la transformation
    transform()
    # Lancement de la phase du chargement
    load_dwh()
    # Fermeture propre de la connexion à la fin
    connexion.close()
    print("\n Pipeline ETL terminé et connexion fermée.")

# Point d'entrée standard en Python
if __name__ == "__main__":
    orchestractor()