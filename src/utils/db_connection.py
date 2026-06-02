
import psycopg2

def conn():
    con = psycopg2.connect(
        dbname="olist_ecom",
        user = "postgres",
        password = "0000",
        host = "localhost"
    )
    return con