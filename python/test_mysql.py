
import mysql.connector
from getpass import getpass

mot_de_passe = getpass("Mot de passe MySQL : ")

connexion = mysql.connector.connect(
    host="localhost",
    port=3306,
    user="root",
    password=mot_de_passe,
    database="velibdb"
)

print("Connexion MySQL réussie !")

curseur = connexion.cursor()
curseur.execute("SHOW TABLES")

for table in curseur:
    print(table[0])

curseur.close()
connexion.close()
