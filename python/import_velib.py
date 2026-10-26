
import json
import getpass
from datetime import datetime
import mysql.connector

# 1. Lecture du fichier JSON
with open("velib.json", "r", encoding="utf-8") as fichier:
    stations = json.load(fichier)

# 2. Connexion à MySQL
mot_de_passe = getpass.getpass("Mot de passe MySQL : ")

connexion = mysql.connector.connect(
    host="localhost",
    user="root",
    password=mot_de_passe,
    database="velibdb"
)

curseur = connexion.cursor()

# 3. Requête d'insertion ou de mise à jour
requete = """
INSERT INTO station_dispo (
    stationcode, name, is_installed, capacity,
    numdocksavailable, numbikesavailable,
    mechanical, ebike, is_renting, is_returning,
    duedate, lat, lon, commune, code_insee,
    station_opening_hours
)
VALUES (
    %s, %s, %s, %s,
    %s, %s, %s,
    %s, %s, %s,
    %s, %s, %s, %s, %s, %s
)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    is_installed = VALUES(is_installed),
    capacity = VALUES(capacity),
    numdocksavailable = VALUES(numdocksavailable),
    numbikesavailable = VALUES(numbikesavailable),
    mechanical = VALUES(mechanical),
    ebike = VALUES(ebike),
    is_renting = VALUES(is_renting),
    is_returning = VALUES(is_returning),
    duedate = VALUES(duedate),
    lat = VALUES(lat),
    lon = VALUES(lon),
    commune = VALUES(commune),
    code_insee = VALUES(code_insee),
    station_opening_hours = VALUES(station_opening_hours)
"""

# 4. Préparation des données
donnees = []

for station in stations:
    date_brute = station.get("duedate")

    date_mysql = None
    if date_brute:
        date_mysql = datetime.fromisoformat(
            date_brute.replace("Z", "+00:00")
        ).replace(tzinfo=None)

    coordonnees = station.get("coordonnees_geo") or {}

    horaires = station.get("station_opening_hours")
    if isinstance(horaires, (dict, list)):
        horaires = json.dumps(horaires, ensure_ascii=False)

    valeurs = (
        station["stationcode"],
        station["name"],
        station.get("is_installed"),
        station.get("capacity"),
        station.get("numdocksavailable"),
        station.get("numbikesavailable"),
        station.get("mechanical"),
        station.get("ebike"),
        station.get("is_renting"),
        station.get("is_returning"),
        date_mysql,
        coordonnees.get("lat"),
        coordonnees.get("lon"),
        station.get("nom_arrondissement_communes"),
        station.get("code_insee_commune"),
        horaires
    )

    donnees.append(valeurs)

# 5. Importation dans MySQL
try:
    curseur.executemany(requete, donnees)
    connexion.commit()

    curseur.execute("SELECT COUNT(*) FROM station_dispo")
    total = curseur.fetchone()[0]

    print("Importation terminée !")
    print("Stations dans le JSON :", len(stations))
    print("Stations dans MySQL :", total)

except mysql.connector.Error as erreur:
    connexion.rollback()
    print("Erreur MySQL :", erreur)

finally:
    curseur.close()
    connexion.close()
