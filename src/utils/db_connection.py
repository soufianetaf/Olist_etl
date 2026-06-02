import psycopg2
from dotenv import load_dotenv, find_dotenv
import os
load_dotenv(find_dotenv())

def get_connexion():
    """
    creer connexion avec notre base de donnees
    Sorties :
    conn : retourner la connexion a la base de données
    """

    try :
        conn = psycopg2.connect(
            host=os.getenv("db_host"),
            database = os.getenv("db_name"),
            user= os.getenv("dv_user"),
            password = os.getenv("db_password")
        )

        print("Connexion a la base de données est reussie.")
        return conn
    except Exception as e:
        print("Erreur a la connexion a la base de données")
        print(f"Details de l'erreur: {e}")
        return None