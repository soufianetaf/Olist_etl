import os

def execute_sql(connexion, file_path):
    """
    ouvre un fichier .sql, lire son contenu et executer sur PostgreSql

    parmateres :
    connexion : objet de connexion psycopg2 à la base de donnée 
    path : le url de notre fichier.sql
    """

    if not os.path.exists(file_path):
        print(f"Erreur : le chemin : {file_path}  est inccorect ")
    with open(file_path, 'r', encoding = 'utf-8') as f :
        query = f.read()
        try :
            cur = connexion.cursor()

            print(f"Exécution en cours ... : {file_path} ")
            cur.execute(query)
            connexion.commit()
            print(f"Succées : {file_path} terminé ")
            cur.close()
            return True
        
        except Exception as e :
            print(f"Echec lors de l'execution de {file_path}")
            print(f"Détaills de l'erreur : {e}")
            connexion.rollback()
            print("Rollback effectué : base de données reste intacte.")
            if 'cur' in locals() and cur is not  None :
                cur.close()
                return False

