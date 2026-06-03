import os


def load(connexion,table_name, file_path):
    """
    Inserer un fichier cvs dans une table dans notre database

    Paramétres :
    connexion : objet de connexion psycopg2 a base de données 
    path : le chemin de notre fichier .csv
    """

    if not  os.path.exists(file_path): 
        print(f"le chmein : {file_path} est introuvable")
        return False
    with open(file_path, 'r', encoding='utf-8-sig') as f :
        try :
            cur = connexion.cursor()
            print(f"Instertion des données dans {table_name} depuis {file_path} est en cours...")
            query = f"COPY {table_name}  FROM STDIN WITH CSV HEADER DELIMITER ','"
            cur.copy_expert(query, f)
            connexion.commit()
            print(f"Insertion completes")
            cur.close()
            return True
        except Exception as e :
            print(f"Un erreur trouvée lors de l'insertion dans {table_name} depuis {file_path}")
            print(f"Details de l'erreur : {e}")
            connexion.rollback()
            print("Rollback effectuer : base donnees maintenant est intacte")
            if 'cur' in locals() and cur is not None : 
                cur.close()
                return False