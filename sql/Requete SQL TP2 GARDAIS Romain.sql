
USE velibdb;

-- Photo instantanée : 1 ligne par station
CREATE TABLE IF NOT EXISTS station_dispo (
    stationcode           VARCHAR(10) NOT NULL PRIMARY KEY,
    name                  VARCHAR(150) NOT NULL,
    is_installed          ENUM('OUI','NON'),
    capacity              SMALLINT,
    numdocksavailable     SMALLINT,
    numbikesavailable     SMALLINT,
    mechanical            SMALLINT,
    ebike                 SMALLINT,
    is_renting            ENUM('OUI','NON'),
    is_returning          ENUM('OUI','NON'),
    duedate               DATETIME NULL,
    lat                   DECIMAL(10,7),
    lon                   DECIMAL(10,7),
    commune               VARCHAR(100),
    code_insee            CHAR(5),
    station_opening_hours VARCHAR(255) NULL
);





USE velibdb;

-- Historique : 1 ligne par station et par relevé
CREATE TABLE IF NOT EXISTS station_historique (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    releve_at         DATETIME NOT NULL,
    stationcode       VARCHAR(10) NOT NULL,
    capacity          SMALLINT,
    numdocksavailable SMALLINT,
    numbikesavailable SMALLINT,
    mechanical        SMALLINT,
    ebike             SMALLINT,
    is_renting        ENUM('OUI','NON'),
    INDEX idx_releve (releve_at),
    INDEX idx_station (stationcode)
);





USE velibdb;

SHOW TABLES;




USE velibdb;

SELECT 'station_dispo' AS nom_table,
       COUNT(*) AS nombre_lignes
FROM station_dispo

UNION ALL

SELECT 'station_historique' AS nom_table,
       COUNT(*) AS nombre_lignes
FROM station_historique;




USE velibdb;

SELECT
    stationcode,
    name,
    commune,
    capacity,
    numbikesavailable,
    mechanical,
    ebike,
    duedate
FROM station_dispo
LIMIT 20;




USE velibdb;

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
    duedate,
    stationcode,
    capacity,
    numdocksavailable,
    numbikesavailable,
    mechanical,
    ebike,
    is_renting
FROM station_dispo
WHERE duedate IS NOT NULL;




SELECT COUNT(*) AS nombre_releves
FROM station_historique;





USE velibdb;

SELECT
    stationcode,
    releve_at,
    capacity,
    numbikesavailable,
    mechanical,
    ebike
FROM station_historique
ORDER BY releve_at DESC
LIMIT 20;





USE velibdb;

SELECT
    stationcode,
    releve_at,
    COUNT(*) AS nombre
FROM station_historique
GROUP BY stationcode, releve_at
HAVING COUNT(*) > 1;





USE velibdb;

ALTER TABLE station_historique
ADD CONSTRAINT uq_station_releve
UNIQUE (stationcode, releve_at);





USE velibdb;

SELECT
    DATE_FORMAT(releve_at, '%Y-%m-%d %H:%i:%s') AS date_releve,
    COUNT(*) AS nombre_stations
FROM station_historique
GROUP BY releve_at
ORDER BY releve_at DESC;





USE velibdb;

SELECT
    COUNT(*) AS total_enregistrements,
    COUNT(DISTINCT stationcode) AS stations_distinctes,
    COUNT(DISTINCT releve_at) AS horodatages_distincts,
    MIN(releve_at) AS premier_releve,
    MAX(releve_at) AS dernier_releve
FROM station_historique;





USE velibdb;

SELECT
    stationcode,
    releve_at,
    capacity,
    numbikesavailable
FROM station_historique
WHERE releve_at < '2026-10-23 00:00:00'
ORDER BY releve_at ASC
LIMIT 20;



SELECT
    COUNT(*) AS nombre_lignes,
    COUNT(DISTINCT releve_at) AS nombre_releves,
    MIN(releve_at) AS premier_releve,
    MAX(releve_at) AS dernier_releve,
    COUNT(DISTINCT CASE
        WHEN HOUR(releve_at) = 8 THEN releve_at
    END) AS releves_8h,
    COUNT(DISTINCT CASE
        WHEN HOUR(releve_at) = 18 THEN releve_at
    END) AS releves_18h
FROM velibdb.station_historique;


USE velibdb;

SELECT
    DATE(releve_at) AS date_releve,
    HOUR(releve_at) AS heure,
    COUNT(*) AS nombre_lignes,
    COUNT(DISTINCT stationcode) AS nombre_stations,
    MIN(releve_at) AS premier_horodatage,
    MAX(releve_at) AS dernier_horodatage
FROM station_historique
WHERE HOUR(releve_at) IN (8, 18)
GROUP BY
    DATE(releve_at),
    HOUR(releve_at)
ORDER BY
    date_releve DESC,
    heure ASC;




USE velibdb;

SELECT
    HOUR(releve_at) AS heure,
    COUNT(*) AS nombre_lignes,
    COUNT(DISTINCT stationcode) AS nombre_stations,
    COUNT(DISTINCT releve_at) AS nombre_releves,
    MIN(releve_at) AS premier_releve,
    MAX(releve_at) AS dernier_releve
FROM station_historique
WHERE HOUR(releve_at) IN (9, 19)
GROUP BY HOUR(releve_at)
ORDER BY heure;



SELECT
    DATE(releve_at) AS date_releve,
    COUNT(*) AS nombre_lignes,
    COUNT(DISTINCT releve_at) AS nombre_releves,
    COUNT(DISTINCT stationcode) AS nombre_stations
FROM station_historique
GROUP BY DATE(releve_at)
ORDER BY date_releve;




SELECT
    HOUR(releve_at) AS heure,
    COUNT(*) AS nombre_lignes,
    COUNT(DISTINCT stationcode) AS nombre_stations,
    ROUND(AVG(numbikesavailable), 2) AS moyenne_velos,
    SUM(numbikesavailable) AS total_velos
FROM station_historique
WHERE DATE(releve_at) = '2026-10-23'
  AND HOUR(releve_at) IN (12, 15)
GROUP BY HOUR(releve_at)
ORDER BY heure;
