
import getpass
from datetime import datetime
from zoneinfo import ZoneInfo
import mysql.connector

# Connexion à MySQL
mot_de_passe = getpass.getpass("Mot de passe MySQL : ")

connexion = mysql.connector.connect(
    host="localhost",
    user="root",
    password=mot_de_passe,
    database="velibdb"
)

curseur = connexion.cursor()

# Horodatage du relevé
releve = datetime.now(ZoneInfo("Europe/Paris")).replace(
    second=0,
    microsecond=0,
    tzinfo=None
)

# Enregistrement de l'état actuel des stations
requete = """
INSERT INTO station_historique (
    releve_at,
    stationcode,
    capacity,
    numdocksavailable,
    numbikesavailable,
    mechanical,
    ebike,
    is_renting
)
SELECT
    %s,
    stationcode,
    capacity,
    numdocksavailable,
    numbikesavailable,
    mechanical,
    ebike,
    is_renting
FROM station_dispo
"""

try:
    curseur.execute(requete, (releve,))
    nombre = curseur.rowcount
    connexion.commit()

    print("Collecte historique terminee !")
    print("Date du releve :", releve)
    print("Stations enregistrees :", nombre)

except mysql.connector.Error as erreur:
    connexion.rollback()
    print("Erreur MySQL :", erreur)

finally:
    curseur.close()
    connexion.close()
