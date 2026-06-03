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

def orchestractor():
    """Le chef d'orchestre de notre ETL"""
    print(" Début de notre pipeline ETL...")
    
    # Si la connexion a échoué, on arrête tout
    if connexion is None:
        print(" Pipeline annulé : Impossible de se connecter à la base.")
        return

    # Lancement de la phase d'extraction
    extract()
    
    # Fermeture propre de la connexion à la fin
    connexion.close()
    print("\n Pipeline ETL terminé et connexion fermée.")

# Point d'entrée standard en Python
if __name__ == "__main__":
    orchestractor()