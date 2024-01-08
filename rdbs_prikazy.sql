-- Select pro průměrný počet záznamů na tabulky v DB
SELECT AVG(table_rows) AS average_row_count
FROM information_schema.tables
WHERE table_schema = 'systemsdb'
      AND table_type = 'BASE TABLE'

-- Select pro celkový počet záznamů pro tabulky planets, stars a systems v DB
SELECT SUM(subquery.table_rows) AS total_row_count
FROM (
    SELECT table_name, table_rows
    FROM information_schema.tables
    WHERE table_name IN ('planets', 'stars', 'systems')
          AND table_schema = 'systemsdb'
          AND table_type = 'BASE TABLE'
) AS subquery

-- Select pro celkový počet záznamů v tabulce planets
SELECT SUM(row_count) AS total_rows
FROM (
    SELECT COUNT(*) AS row_count
    FROM planets
) AS subquery;

-- jeden SELECT bude řešit rekurzi nebo hierarchii (JOIN)
SELECT s.name AS system_name, st.name AS station_name, GROUP_CONCAT(se.name) AS all_services, p.name AS planet_name, st.maxPadSize_id, a.name AS allegiance_name
FROM systems s
RIGHT JOIN stations st ON s.id = st.system_id
LEFT JOIN station_service ss ON s.id = ss.station_id
LEFT JOIN services se ON ss.service_id = se.id
LEFT JOIN planets p ON st.planet_id = p.id
JOIN allegiances a ON st.allegiance_id = a.id
GROUP BY st.id

-- View generátor
CREATE VIEW stations_systems AS
SELECT s.name AS system_name, st.name AS station_name, GROUP_CONCAT(se.name) AS all_services, p.name AS planet_name, st.maxPadSize_id, a.name AS allegiance_name
FROM systems s
RIGHT JOIN stations st ON s.id = st.system_id
LEFT JOIN station_service ss ON s.id = ss.station_id
LEFT JOIN services se ON ss.service_id = se.id
LEFT JOIN planets p ON st.planet_id = p.id
JOIN allegiances a ON st.allegiance_id = a.id
GROUP BY st.id

-- Select pro vyhledání v tabulce -pozn.: takto vyhledává podle indexu, u atmosphere index nebyl, tak to hodilo error
SELECT * FROM planets WHERE MATCH (volcanism) AGAINST ('magma');

-- Funkce pro výpočet průměrného radiusu planet
DELIMITER //

CREATE FUNCTION avg_planet_radius()
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE avg_radius DECIMAL(10,2);
    
    SELECT AVG(radius) INTO avg_radius FROM planets;
    
    RETURN avg_radius;
END //

DELIMITER ;

-- Procedura
DELIMITER //

CREATE PROCEDURE process_planets_with_systems()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE planet_id INT;
    DECLARE planet_name VARCHAR(255);
    DECLARE system_id INT;
    DECLARE system_name VARCHAR(255);

    DECLARE cur CURSOR FOR 
    SELECT p.id, p.name, p.system_id
    FROM planets p;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
    END;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO planet_id, planet_name, system_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Získání informací o systému pro aktuální planetu
        SELECT name INTO system_name FROM systems WHERE id = system_id;

        -- Výpis informací o planetě a systému
        SELECT CONCAT('Planet ID: ', planet_id, ', Name: ', planet_name, ', System: ', system_name);

    END LOOP;

    CLOSE cur;
END //

DELIMITER ;
-------------------------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE process_planets_by_system(IN system_id_param INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE planet_id INT;
    DECLARE planet_name VARCHAR(255);
    DECLARE system_name VARCHAR(255);

    DECLARE cur CURSOR FOR 
        SELECT p.id, p.name, p.system_id
        FROM planets p
        WHERE p.system_id = system_id_param;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
    END;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO planet_id, planet_name, system_id_param;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT name INTO system_name FROM systems WHERE id = system_id_param;

        SELECT CONCAT('Planet ID: ', planet_id, ', Name: ', planet_name, ', System: ', system_name);

    END LOOP;

    CLOSE cur;
END //

DELIMITER ;

--Trigger
DELIMITER //

CREATE TRIGGER planets_after_insert
AFTER INSERT ON planets FOR EACH ROW
BEGIN
    -- Zde můžeš provést akce, které se mají stát po vložení záznamu do tabulky planets
    INSERT INTO audit_table (action, table_name, record_id, user, timestamp)
    VALUES ('INSERT', 'planets', NEW.id, CURRENT_USER(), NOW());
END //

DELIMITER ;

-- Transakce
DELIMITER //

CREATE PROCEDURE process_planets_transaction(IN system_id_param INT)
BEGIN
    DECLARE system_name VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT CONCAT('Planet ID: ', p.id, ', Name: ', p.name, ', System: ', s.name)
    FROM planets p
    JOIN systems s ON p.system_id = s.id
    WHERE p.system_id = system_id_param;

    COMMIT;
END //

DELIMITER ;
/*
Tato procedura obsahuje blok transakce začínající pomocí START TRANSACTION a ukončující se COMMIT. 
Pokud dojde k chybě (zde ošetřeno pomocí SQLEXCEPTION), dojde k rollbacku transakce a žádné změny nebudou aplikovány.
*/

-- User
-- Lock
SELECT s.name AS system_name, st.name AS station_name, GROUP_CONCAT(se.name) AS all_services, 
    p.name AS planet_name, st.maxPadSize_id, a.name AS allegiance_name  
FROM systems s  
RIGHT JOIN stations st ON s.id = st.system_id  
LEFT JOIN station_service ss ON s.id = ss.station_id  
LEFT JOIN services se ON ss.service_id = se.id  
LEFT JOIN planets p ON st.planet_id = p.id  
JOIN allegiances a ON st.allegiance_id = a.id  
WHERE MATCH(s.name) AGAINST(:search_term IN BOOLEAN MODE) 
    OR MATCH(st.name) AGAINST(:search_term IN BOOLEAN MODE) 
    OR MATCH(se.name) AGAINST(:search_term IN BOOLEAN MODE) 
    OR MATCH(p.name) AGAINST(:search_term IN BOOLEAN MODE) 
    OR MATCH(a.name) AGAINST(:search_term IN BOOLEAN MODE)
GROUP BY st.id 
LOCK IN SHARE MODE;
-- MariaDB nepodporuje LOCK klauzuli v dotazech SELECT
-- Tento dotaz používá LOCK IN SHARE MODE na konci dotazu, což umožňuje přečtení dat s nižší úrovní izolace transakce, ale zároveň zabraňuje zámku záznamů.

-- ORM \ hotové
