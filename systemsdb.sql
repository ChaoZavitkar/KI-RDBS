-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Počítač: 127.0.0.1
-- Vytvořeno: Pon 08. led 2024, 23:37
-- Verze serveru: 10.4.11-MariaDB
-- Verze PHP: 7.4.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Databáze: `systemsdb`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `process_planets_by_system` (IN `system_id_param` INT)  BEGIN
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

        SELECT CONCAT('Planet ID: ', planet_id, ', Name: ', planet_name, ', System: ', system_name) AS planet;

    END LOOP;

    CLOSE cur;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `process_planets_transaction` (IN `system_id_param` INT)  BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `process_planets_with_systems` ()  BEGIN
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
        SELECT CONCAT('Planet ID: ', planet_id, ', Name: ', planet_name, ', System: ', system_name) AS planet;

    END LOOP;

    CLOSE cur;
END$$

--
-- Funkce
--
CREATE DEFINER=`root`@`localhost` FUNCTION `avg_planet_radius` () RETURNS DECIMAL(10,2) BEGIN
    DECLARE avg_radius DECIMAL(10,2);
    
    SELECT AVG(radius) INTO avg_radius FROM planets;
    
    RETURN avg_radius;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabulky `allegiances`
--

CREATE TABLE `allegiances` (
  `id` int(11) NOT NULL,
  `name` varchar(20) COLLATE utf8_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `allegiances`
--

INSERT INTO `allegiances` (`id`, `name`) VALUES
(1, 'Independent'),
(2, 'Alliance'),
(3, 'Empire'),
(4, 'Federation'),
(5, 'Pirate'),
(6, 'Pilots Federation'),
(7, 'Thargoids'),
(8, 'Guardians');

-- --------------------------------------------------------

--
-- Struktura tabulky `audit_table`
--

CREATE TABLE `audit_table` (
  `id` int(11) NOT NULL,
  `action` varchar(50) COLLATE utf8_czech_ci DEFAULT NULL,
  `table_name` varchar(50) COLLATE utf8_czech_ci DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `user` varchar(50) COLLATE utf8_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `audit_table`
--

INSERT INTO `audit_table` (`id`, `action`, `table_name`, `record_id`, `timestamp`, `user`) VALUES
(2, 'INSERT', 'planets', 18, '2024-01-08 11:49:18', 'root@localhost');

-- --------------------------------------------------------

--
-- Zástupná struktura pro pohled `my_view`
-- (See below for the actual view)
--
CREATE TABLE `my_view` (
`system_name` varchar(40)
,`planet_name` varchar(20)
,`isTerraformed` bit(1)
,`possibleMining` bit(1)
,`radius` int(11)
,`temperature` decimal(10,0)
,`volcanism` varchar(50)
,`atmosphere` varchar(50)
,`type_name` varchar(50)
);

-- --------------------------------------------------------

--
-- Struktura tabulky `padsizes`
--

CREATE TABLE `padsizes` (
  `id` varchar(1) COLLATE utf8_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `padsizes`
--

INSERT INTO `padsizes` (`id`) VALUES
('L'),
('M'),
('S');

-- --------------------------------------------------------

--
-- Struktura tabulky `planets`
--

CREATE TABLE `planets` (
  `id` int(11) NOT NULL,
  `name` varchar(20) COLLATE utf8_czech_ci NOT NULL,
  `isTerraformed` bit(1) NOT NULL,
  `possibleMining` bit(1) NOT NULL,
  `radius` int(11) NOT NULL,
  `temperature` decimal(10,0) NOT NULL,
  `volcanism` varchar(50) COLLATE utf8_czech_ci NOT NULL,
  `atmosphere` varchar(50) COLLATE utf8_czech_ci NOT NULL,
  `system_id` int(11) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `planets`
--

INSERT INTO `planets` (`id`, `name`, `isTerraformed`, `possibleMining`, `radius`, `temperature`, `volcanism`, `atmosphere`, `system_id`, `type_id`) VALUES
(1, 'Mercury', b'0', b'1', 2440, '129', '', '', 1, 14),
(2, 'Venus', b'0', b'1', 6052, '462', 'Minor Rocky magma', 'Hot Thick Carbon dioxide', 1, 12),
(3, 'Earth', b'1', b'1', 6378, '15', 'Rocky magma', 'Suitable for water-based life', 1, 7),
(4, 'Jupiter', b'0', b'0', 71492, '-126', '', '', 1, 2),
(5, 'Tethlon', b'1', b'0', 6310, '25', '', 'Suitable for water-based life', 4, 7),
(6, 'LTT 9360 B 11', b'0', b'1', 8248, '15', '', 'Helium', 5, 11),
(7, 'LTT 9360 B 9 e', b'0', b'0', 7962, '-19', '', '', 5, 2),
(8, 'LTT 9360 B 8', b'1', b'0', 5170, '124', '', '', 5, 3),
(9, 'Asellus 1', b'0', b'1', 4398, '204', 'Rocky magma', '', 7, 14),
(10, 'Asellus 2', b'0', b'1', 4877, '29', '', 'Suitable for water-based life', 7, 18),
(11, 'Asellus 3', b'0', b'1', 8542, '10', '', '', 7, 8),
(12, 'DX 799 ABC 1', b'0', b'1', 8217, '10', '', '', 15, 19),
(13, 'Fusang 5', b'1', b'1', 3432, '25', '', '', 14, 9),
(14, 'Barnard\'s Star 2', b'1', b'1', 4058, '30', '', '', 3, 7),
(15, 'Wolf 718 10', b'0', b'1', 9502, '-157', '', '', 18, 10),
(17, 'HD 40307g', b'0', b'1', 2440, '25', 'Rocky magma', '', 2, 11),
(18, 'Eta Carinae', b'1', b'0', 71492, '15', 'Rocky magma', '', 31, 4);

--
-- Spouště `planets`
--
DELIMITER $$
CREATE TRIGGER `planets_after_insert` AFTER INSERT ON `planets` FOR EACH ROW BEGIN
    INSERT INTO audit_table (action, table_name, record_id, user, timestamp)
    VALUES ('INSERT', 'planets', NEW.id, CURRENT_USER(), NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabulky `powerplays`
--

CREATE TABLE `powerplays` (
  `id` int(11) NOT NULL,
  `name` varchar(20) COLLATE utf8_czech_ci NOT NULL,
  `generalEffect` varchar(255) COLLATE utf8_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `powerplays`
--

INSERT INTO `powerplays` (`id`, `name`, `generalEffect`) VALUES
(1, 'Aisling Duval', 'Influence gains boost for Imperial minor factions, reduced for Federation.\r\nWeapon: Prismatic Shield Generator [Provides strong shields]'),
(2, 'Archon Delaine', 'All factional Influence decreases, but favours Independents over Federation & Empire\r\nWeapon: Cytoscrambler [Burst laser effective against shields, not hull]'),
(3, 'Arissa Lavigny-Duval', 'Influence gains boost for Empire minor factions, reduced for Federation.\r\nWeapon: Imperial Hammer [Railgun, causes multi-shot damage]'),
(4, 'Denton Patreus', 'Influence gains boost for Imperial minor factions, reduced for Federation.\r\nWeapon: Advanced Accelerator [Plasma Accelerator, specialist plasma weapon]'),
(5, 'Edmund Mahon', 'Influence gain for Alliance minor factions, reduced for Federation & Empire\r\nWeapon: Retributor [Small laser inflicts enhanced damage]'),
(6, 'Felicia Winters', 'Influence gains boost for Federal minor factions, reduced for Imperial Exploited Systems\r\nWeapon: Pulse Disruptor [Medium Laser, causes module malfunction]'),
(7, 'Li Yong-Rui', 'All factional Influence decreases, but more so for Federation & Empire\r\nWeapon: Pack-hound Missile Rack [Launches salvo of ‘drunken’ seeker missiles]'),
(8, 'Pranav Antal', 'Increase in influence in all factions, but favours Independents over Federation & Empire\r\nWeapon: Enforcer Canon [Reduced fire rate, higher damage]'),
(9, 'Yuri Grom', 'Weapon: Containment Missile [A dumbfire missile that temporarily disrupts and reboots the target vessel\'s frame shift drive]'),
(10, 'Zachary Hudson', 'Influence gains boost for Federal minor factions\r\nReduced for Imperial Exploited Systems\r\nWeapon: Pacifier Frag-Cannon [Lower Damage, Longer Range, Tighter Spread]'),
(11, 'Zemina Torval', 'Influence gains boost for Imperial minor factions, reduced for Federation.\r\nWeapon: Mining Lance [Mining Laser, capable of inflicting combat damage]');

-- --------------------------------------------------------

--
-- Struktura tabulky `services`
--

CREATE TABLE `services` (
  `id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `services`
--

INSERT INTO `services` (`id`, `name`) VALUES
(1, 'Commodity market'),
(2, 'Concourse'),
(3, 'Contacts'),
(4, 'Crew lounge'),
(5, 'Fleet carrier administration'),
(6, 'Fleet carrier services'),
(7, 'Fleet carrier vendor'),
(8, 'Frontline Solutions'),
(9, 'Interstellar factors'),
(10, 'Material trader'),
(11, 'Missions'),
(12, 'Outfitting'),
(13, 'Pioneer Supplies'),
(14, 'Rearm'),
(15, 'Redemption office'),
(16, 'Refuel'),
(17, 'Repair'),
(18, 'Search and rescue'),
(19, 'Shipyard'),
(20, 'Technology broker'),
(21, 'Tuning'),
(22, 'Universal Cartograph'),
(23, 'Vendors'),
(24, 'Vista Genomics'),
(25, 'Workshop');

-- --------------------------------------------------------

--
-- Struktura tabulky `stars`
--

CREATE TABLE `stars` (
  `id` int(11) NOT NULL,
  `system_id` int(11) DEFAULT NULL,
  `name` varchar(20) COLLATE utf8_czech_ci NOT NULL,
  `starType_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `stars`
--

INSERT INTO `stars` (`id`, `system_id`, `name`, `starType_id`) VALUES
(1, 1, 'Sol', 8),
(2, 2, 'Alpha Centauri', 8),
(3, 2, 'Alpha Centauri B', 10),
(4, 2, 'Proxima Centauri', 12),
(5, 3, 'Salleda A', 12),
(6, 3, 'Salleda B', 39),
(7, 4, 'Tethlon', 8),
(8, 5, 'LTT 9360', 10),
(9, 5, 'Gliese 889 B', 12),
(10, 6, 'Monto A', 12),
(11, 6, 'Monto B', 12),
(12, 6, 'Monto C', 40),
(13, 6, 'Monto D', 39),
(14, 7, 'Asellus Primus', 6),
(15, 7, 'Asellus Primus B', 12),
(16, 8, 'Orna', 39),
(17, 9, 'Bumbo', 12),
(18, 10, 'Liu Hef A', 12),
(19, 10, 'Liu Hef B', 12),
(20, 10, 'Liu Hef C', 40),
(21, 10, 'Liu Hef D', 12),
(22, 11, 'Ross 490', 12),
(23, 12, 'Xi Ursae Majoris', 8),
(24, 12, 'Xi Ursae Majoris B', 8),
(25, 13, 'LHS 3713 A', 12),
(26, 13, 'LHS 3713 B', 40),
(27, 14, 'FF Andromedae A', 12),
(28, 14, 'FF Andromedae B', 40),
(29, 15, 'EQ Pegasi', 12),
(30, 15, 'BD+19 5116 B', 12),
(31, 16, 'Ross 775', 12),
(32, 17, 'EZ Aquarii', 12),
(33, 18, 'IL Aquarii', 12),
(34, 19, 'Athra', 40),
(35, 20, '10 Tauri', 6),
(36, 2, 'Barnard\'s Star', 34),
(37, 4, 'Wolf 359', 35),
(38, 6, 'Lalande 21185', 36),
(39, 8, '61 Cygni', 37),
(40, 10, 'Eta Carinae', 38),
(41, 12, 'Betelgeuse', 39),
(42, 14, 'Rigel', 40),
(43, 16, 'Deneb', 41),
(44, 18, 'Altair', 42),
(45, 20, 'Vega', 43),
(46, 22, 'Capella', 44),
(47, 24, 'Achernar', 45),
(48, 26, 'Fomalhaut', 46),
(49, 28, 'Pollux', 47),
(50, 30, 'Procyon', 48),
(51, 32, 'Arcturus', 49),
(52, 34, 'Spica', 50),
(53, 36, 'Regulus', 1),
(54, 38, 'Antares', 2),
(55, 40, 'Gliese 581', 3),
(56, 42, 'Gliese 667C', 4),
(57, 44, 'Trappist-1', 5),
(58, 46, 'Kepler-186f', 6),
(59, 48, 'Proxima Centauri', 7),
(60, 50, 'Ross 128b', 8),
(61, 3, 'Barnard\'s Star b', 9),
(62, 5, 'GJ 436b', 10),
(63, 7, 'HD 40307g', 11),
(64, 9, 'HD 156668b', 12),
(65, 11, 'HD 10180f', 13),
(66, 13, 'HD 189733b', 14),
(67, 15, 'GJ 667C c', 15),
(68, 17, 'GJ 667C d', 16),
(69, 21, '2', 17),
(70, 23, '3', 18),
(71, 25, '4', 19),
(72, 27, '5', 20),
(73, 29, '6', 21),
(74, 31, '7', 22),
(75, 33, '8', 23),
(76, 35, '9', 24),
(77, 37, '10', 25),
(78, 39, '11', 26),
(79, 41, '12', 27),
(80, 43, '13', 28),
(81, 45, '14', 29),
(82, 47, '15', 30),
(83, 49, '16', 31),
(84, 51, '17', 32),
(85, 53, '18', 33);

-- --------------------------------------------------------

--
-- Struktura tabulky `startypes`
--

CREATE TABLE `startypes` (
  `id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `startypes`
--

INSERT INTO `startypes` (`id`, `name`) VALUES
(1, 'Class O star'),
(2, 'Class B star'),
(3, 'Class B star (blue-white super giant)'),
(4, 'Class A star'),
(5, 'Class A star (blue-white super giant)'),
(6, 'Class F star'),
(7, 'Class F star (white super giant)'),
(8, 'Class G star'),
(9, 'Class G star (white-yellow super giant)'),
(10, 'Class K star'),
(11, 'Class K star (orange giant)'),
(12, 'Class M star'),
(13, 'Class M star (red giant)'),
(14, 'Class M star (red super giant)'),
(15, 'Class C star'),
(16, 'Class CH star'),
(17, 'Class CHD star'),
(18, 'Class CJ star'),
(19, 'Class CN star'),
(20, 'Class CS star'),
(21, 'MS-type star'),
(22, 'S-type star'),
(23, 'Class D star (white dwarf)'),
(24, 'Class DA star (white dwarf)'),
(25, 'Class DAB star (white dwarf)'),
(26, 'Class DAO star (white dwarf)'),
(27, 'Class DAZ star (white dwarf)'),
(28, 'Class DAV star (white dwarf)'),
(29, 'Class DB star (white dwarf)'),
(30, 'Class DBZ star (white dwarf)'),
(31, 'Class DBV star (white dwarf)'),
(32, 'Class DC star (white dwarf)'),
(33, 'Class DCV star (white dwarf)'),
(34, 'Class DO star (white dwarf)'),
(35, 'Class DOV star (white dwarf)'),
(36, 'Class DQ star (white dwarf)'),
(37, 'Class DX star (white dwarf)'),
(38, 'Class Y star (brown dwarf)'),
(39, 'Class T star (brown dwarf)'),
(40, 'Class L star (brown dwarf)'),
(41, 'Herbig Ae/Be star'),
(42, 'T Tauri star'),
(43, 'Neutron star'),
(44, 'Wolf-Rayet star'),
(45, 'Wolf-Rayet N star'),
(46, 'Wolf-Rayet NC star'),
(47, 'Wolf-Rayet C star'),
(48, 'Wolf-Rayet O star'),
(49, 'Rogue planet'),
(50, 'Nebula'),
(51, 'Stellar remnant nebula'),
(52, 'Exotic'),
(53, 'Black hole'),
(54, 'Supermassive black hole');

-- --------------------------------------------------------

--
-- Struktura tabulky `stations`
--

CREATE TABLE `stations` (
  `id` int(11) NOT NULL,
  `name` varchar(20) COLLATE utf8_czech_ci NOT NULL,
  `system_id` int(11) DEFAULT NULL,
  `planet_id` int(11) DEFAULT NULL,
  `allegiance_id` int(11) DEFAULT NULL,
  `maxPadSize_id` varchar(1) COLLATE utf8_czech_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `stations`
--

INSERT INTO `stations` (`id`, `name`, `system_id`, `planet_id`, `allegiance_id`, `maxPadSize_id`) VALUES
(1, 'Li Qing Jao', 1, 3, 2, 'L'),
(2, 'Indongo Bay', 14, NULL, 7, 'M'),
(3, 'Hidalgo\'s Slumber', 20, NULL, 8, 'L'),
(4, 'Abraham Lincoln', 1, NULL, 3, 'L'),
(5, 'M.Gorbachev', 9, 4, 4, 'M'),
(6, 'Titan City', 2, NULL, 1, 'L'),
(7, 'Ji\'s Slumber', 15, NULL, 6, 'L'),
(8, 'Seidel\'s Globe', 19, NULL, 7, 'S'),
(9, 'Pavlenko\'s Reception', 5, 6, 2, 'L'),
(10, 'Kvitka\'s Origin', 11, NULL, 2, 'S'),
(11, 'Daimler Camp', 18, NULL, 3, 'S'),
(12, 'Mars High', 1, NULL, 3, 'M'),
(13, 'Ehrlich City', 10, NULL, 1, 'S'),
(14, 'Walz Depot', 8, NULL, 2, 'L'),
(15, 'Durrance Camp', 4, NULL, 3, 'L'),
(16, 'Hao\'s Steal', 18, 10, 4, 'M'),
(17, 'Malins\'s Camp', 12, NULL, 1, 'M'),
(18, 'Oshpak\'s House', 16, NULL, 7, 'L'),
(19, 'Grebby Prospecting', 13, 13, 5, 'L'),
(20, 'Illy Enterprise +++', 1, NULL, 1, 'L');

-- --------------------------------------------------------

--
-- Zástupná struktura pro pohled `stations_systems`
-- (See below for the actual view)
--
CREATE TABLE `stations_systems` (
`system_name` varchar(40)
,`station_name` varchar(20)
,`all_services` mediumtext
,`planet_name` varchar(20)
,`maxPadSize_id` varchar(1)
,`allegiance_name` varchar(20)
);

-- --------------------------------------------------------

--
-- Struktura tabulky `station_service`
--

CREATE TABLE `station_service` (
  `station_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `station_service`
--

INSERT INTO `station_service` (`station_id`, `service_id`) VALUES
(1, 13),
(1, 14),
(2, 13),
(2, 18),
(2, 21),
(3, 12),
(4, 1),
(4, 2),
(4, 3),
(4, 4),
(4, 10),
(4, 12),
(4, 14),
(4, 16),
(4, 17),
(4, 21),
(5, 10),
(5, 14),
(6, 3),
(6, 17),
(6, 19),
(7, 7),
(8, 1),
(9, 11),
(10, 14),
(10, 18),
(10, 19),
(11, 1),
(11, 3),
(11, 17),
(11, 20),
(12, 9),
(12, 20),
(13, 3),
(13, 15),
(13, 20),
(14, 3),
(15, 11),
(15, 12),
(15, 15),
(16, 4),
(16, 9),
(16, 13),
(16, 16),
(17, 5),
(17, 17),
(17, 18),
(18, 3),
(18, 5),
(18, 15),
(19, 2),
(19, 9),
(19, 18),
(20, 1),
(20, 12);

-- --------------------------------------------------------

--
-- Struktura tabulky `systems`
--

CREATE TABLE `systems` (
  `id` int(11) NOT NULL,
  `name` varchar(40) COLLATE utf8_czech_ci NOT NULL,
  `population` bigint(20) NOT NULL,
  `allegiance_id` int(11) DEFAULT NULL,
  `powerplay_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `systems`
--

INSERT INTO `systems` (`id`, `name`, `population`, `allegiance_id`, `powerplay_id`) VALUES
(1, 'Sol', 22780000000, 4, 10),
(2, 'Alpha Centauri', 106811, 1, 10),
(3, 'Salleda', 4960000, 1, 1),
(4, 'Tethlon', 250000, 1, 1),
(5, 'LTT 9360', 2050000, 4, 2),
(6, 'Monto', 298260, 3, 2),
(7, 'Asellus Primus', 64998, 6, 5),
(8, 'Orna', 175000, 6, 11),
(9, 'Bumbo', 0, 7, 9),
(10, 'Liu Hef', 0, 7, 5),
(11, 'Ross 490', 16230000, 2, 10),
(12, 'Xi Ursae Majoris', 67990000, 2, 5),
(13, 'LHS 3713', 44070000, 4, 8),
(14, 'FF Andromedae', 27020000, 1, 8),
(15, 'EQ Pegasi', 18330000, 1, 4),
(16, 'Ross 775', 48920000, 4, 5),
(17, 'EZ Aquarii', 9930000, 4, 9),
(18, 'IL Aquarii', 23150000, 4, 9),
(19, 'Athra', 957890000, 4, 7),
(20, '10 Tauri', 10560000, 4, 7),
(21, 'Barnard\'s Star', 100000000, 4, 5),
(22, 'Wolf 359', 100000000, 5, 6),
(23, 'Lalande 21185', 100000000, 6, 7),
(24, '61 Cygni', 100000000, 7, 8),
(25, 'Eta Carinae', 100000000, 8, 1),
(26, 'Betelgeuse', 100000000, 1, 2),
(27, 'Rigel', 100000000, 2, 3),
(28, 'Deneb', 100000000, 3, 4),
(29, 'Altair', 100000000, 2, 5),
(30, 'Vega', 100000000, 1, 6),
(31, 'Capella', 100000000, 4, 7),
(32, 'Achernar', 100000000, 6, 8),
(33, 'Fomalhaut', 100000000, 3, 1),
(34, 'Pollux', 100000000, 8, 2),
(35, 'Procyon', 100000000, 7, 3),
(36, 'Arcturus', 100000000, 5, 4),
(37, 'Spica', 100000000, 4, 5),
(38, 'Regulus', 100000000, 1, 6),
(39, 'Antares', 100000000, 2, 7),
(40, 'Gliese 581', 100000000, 6, 8),
(41, 'Gliese 667C', 100000000, 7, 1),
(42, 'Trappist-1', 100000000, 5, 2),
(43, 'Kepler-186f', 100000000, 8, 3),
(44, 'Proxima Centauri', 100000000, 3, 4),
(45, 'Ross 128b', 100000000, 1, 5),
(46, 'Barnard\'s Star b', 100000000, 2, 6),
(47, 'GJ 436b', 100000000, 3, 7),
(48, 'HD 40307g', 100000000, 4, 8),
(49, 'HD 156668b', 100000000, 5, 1),
(50, 'HD 10180f', 100000000, 6, 2),
(51, 'HD 189733b', 100000000, 7, 3),
(52, 'GJ 667C c', 100000000, 8, 4),
(53, 'GJ 667C d', 100000000, 1, 5);

-- --------------------------------------------------------

--
-- Struktura tabulky `temp_table`
--

CREATE TABLE `temp_table` (
  `system_name` varchar(40) COLLATE utf8_czech_ci,
  `station_name` varchar(20) COLLATE utf8_czech_ci NOT NULL,
  `all_services` mediumtext COLLATE utf8_czech_ci DEFAULT NULL,
  `planet_name` varchar(20) COLLATE utf8_czech_ci,
  `maxPadSize_id` varchar(1) COLLATE utf8_czech_ci DEFAULT NULL,
  `allegiance_name` varchar(20) COLLATE utf8_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `temp_table`
--

INSERT INTO `temp_table` (`system_name`, `station_name`, `all_services`, `planet_name`, `maxPadSize_id`, `allegiance_name`) VALUES
('Sol', 'Li Qing Jao', 'Rearm,Pioneer Supplies', 'Earth', 'L', 'Alliance'),
('FF Andromedae', 'Indongo Bay', 'Contacts', NULL, 'M', 'Thargoids'),
('10 Tauri', 'Hidalgo\'s Slumber', 'Outfitting,Commodity market', NULL, 'L', 'Guardians'),
('Sol', 'Abraham Lincoln', 'Pioneer Supplies,Rearm', NULL, 'L', 'Empire'),
('Bumbo', 'M.Gorbachev', 'Missions', 'Jupiter', 'M', 'Federation'),
('Alpha Centauri', 'Titan City', 'Tuning,Pioneer Supplies,Search and rescue', NULL, 'L', 'Independent'),
('EQ Pegasi', 'Ji\'s Slumber', 'Redemption office,Missions,Outfitting', NULL, 'L', 'Pilots Federation'),
('Athra', 'Seidel\'s Globe', 'Search and rescue,Concourse,Interstellar factors', NULL, 'S', 'Thargoids'),
('LTT 9360', 'Pavlenko\'s Reception', 'Rearm,Material trader', 'LTT 9360 B 11', 'L', 'Alliance'),
('Ross 490', 'Kvitka\'s Origin', 'Technology broker,Contacts,Repair,Commodity market', NULL, 'S', 'Alliance'),
('IL Aquarii', 'Daimler Camp', 'Redemption office,Contacts,Fleet carrier admini', NULL, 'S', 'Empire'),
('Sol', 'Mars High', 'Rearm,Pioneer Supplies', NULL, 'M', 'Empire'),
('Liu Hef', 'Ehrlich City', 'Search and rescue,Shipyard,Rearm', NULL, 'S', 'Independent'),
('Orna', 'Walz Depot', 'Commodity market', NULL, 'L', 'Alliance'),
('Tethlon', 'Durrance Camp', 'Repair,Rearm,Material trader,Contacts,Commodity market,Tuning,Refuel,Outfitting,Crew lounge,Concourse', NULL, 'L', 'Empire'),
('IL Aquarii', 'Hao\'s Steal', 'Fleet carrier admini,Redemption office,Contacts', 'Asellus 2', 'M', 'Federation'),
('Xi Ursae Majoris', 'Malins\'s Camp', 'Interstellar factors,Technology broker', NULL, 'M', 'Independent'),
('Ross 775', 'Oshpak\'s House', 'Refuel,Interstellar factors,Pioneer Supplies,Crew lounge', NULL, 'L', 'Thargoids'),
('LHS 3713', 'Grebby Prospecting', 'Contacts,Redemption office,Technology broker', 'Fusang 5', 'L', 'Pirate'),
('Sol', 'Illy Enterprise +++', 'Pioneer Supplies,Rearm', NULL, 'L', 'Independent');

-- --------------------------------------------------------

--
-- Struktura tabulky `types`
--

CREATE TABLE `types` (
  `id` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

--
-- Vypisuji data pro tabulku `types`
--

INSERT INTO `types` (`id`, `name`) VALUES
(1, 'Ammonia world'),
(2, 'Class I gas giant'),
(3, 'Class II gas giant'),
(4, 'Class III gas giant'),
(5, 'Class IV gas giant'),
(6, 'Class V gas giant'),
(7, 'Earth-like world'),
(8, 'Gas giant with ammonia-based life'),
(9, 'Gas giant with water-based life'),
(10, 'Helium-rich gas giant'),
(11, 'Helium gas giant'),
(12, 'High metal content world'),
(13, 'Icy body'),
(14, 'Metal-rich body'),
(15, 'Rocky body'),
(16, 'Rocky ice world'),
(17, 'Water giant'),
(18, 'Water giant with life'),
(19, 'Water world');

-- --------------------------------------------------------

--
-- Struktura pro pohled `my_view`
--
DROP TABLE IF EXISTS `my_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `my_view`  AS  select `systems`.`name` AS `system_name`,`planets`.`name` AS `planet_name`,`planets`.`isTerraformed` AS `isTerraformed`,`planets`.`possibleMining` AS `possibleMining`,`planets`.`radius` AS `radius`,`planets`.`temperature` AS `temperature`,`planets`.`volcanism` AS `volcanism`,`planets`.`atmosphere` AS `atmosphere`,`types`.`name` AS `type_name` from ((`systems` join `planets` on(`systems`.`id` = `planets`.`system_id`)) join `types` on(`planets`.`type_id` = `types`.`id`)) ;

-- --------------------------------------------------------

--
-- Struktura pro pohled `stations_systems`
--
DROP TABLE IF EXISTS `stations_systems`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `stations_systems`  AS  select `s`.`name` AS `system_name`,`st`.`name` AS `station_name`,group_concat(`se`.`name` separator ',') AS `all_services`,`p`.`name` AS `planet_name`,`st`.`maxPadSize_id` AS `maxPadSize_id`,`a`.`name` AS `allegiance_name` from (((((`stations` `st` left join `systems` `s` on(`s`.`id` = `st`.`system_id`)) left join `station_service` `ss` on(`s`.`id` = `ss`.`station_id`)) left join `services` `se` on(`ss`.`service_id` = `se`.`id`)) left join `planets` `p` on(`st`.`planet_id` = `p`.`id`)) join `allegiances` `a` on(`st`.`allegiance_id` = `a`.`id`)) group by `st`.`id` ;

--
-- Klíče pro exportované tabulky
--

--
-- Klíče pro tabulku `allegiances`
--
ALTER TABLE `allegiances`
  ADD PRIMARY KEY (`id`);
ALTER TABLE `allegiances` ADD FULLTEXT KEY `allegiance_fulltext_name` (`name`);

--
-- Klíče pro tabulku `audit_table`
--
ALTER TABLE `audit_table`
  ADD PRIMARY KEY (`id`);

--
-- Klíče pro tabulku `padsizes`
--
ALTER TABLE `padsizes`
  ADD PRIMARY KEY (`id`);

--
-- Klíče pro tabulku `planets`
--
ALTER TABLE `planets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `system_id` (`system_id`),
  ADD KEY `type_id` (`type_id`);
ALTER TABLE `planets` ADD FULLTEXT KEY `planet_fulltext_index_volcanism` (`volcanism`);
ALTER TABLE `planets` ADD FULLTEXT KEY `planet_name_fulltext_index` (`name`);

--
-- Klíče pro tabulku `powerplays`
--
ALTER TABLE `powerplays`
  ADD PRIMARY KEY (`id`);

--
-- Klíče pro tabulku `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`id`);
ALTER TABLE `services` ADD FULLTEXT KEY `service_fulltext_name` (`name`);

--
-- Klíče pro tabulku `stars`
--
ALTER TABLE `stars`
  ADD PRIMARY KEY (`id`),
  ADD KEY `system_id` (`system_id`),
  ADD KEY `starType_id` (`starType_id`);

--
-- Klíče pro tabulku `startypes`
--
ALTER TABLE `startypes`
  ADD PRIMARY KEY (`id`);

--
-- Klíče pro tabulku `stations`
--
ALTER TABLE `stations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `system_id` (`system_id`),
  ADD KEY `planet_id` (`planet_id`),
  ADD KEY `allegiance_id` (`allegiance_id`),
  ADD KEY `maxPadSize_id` (`maxPadSize_id`);
ALTER TABLE `stations` ADD FULLTEXT KEY `station_fulltext_name` (`name`);

--
-- Klíče pro tabulku `station_service`
--
ALTER TABLE `station_service`
  ADD PRIMARY KEY (`station_id`,`service_id`),
  ADD KEY `service_id` (`service_id`);

--
-- Klíče pro tabulku `systems`
--
ALTER TABLE `systems`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_system_name` (`name`),
  ADD KEY `allegiance_id` (`allegiance_id`),
  ADD KEY `powerplay_id` (`powerplay_id`);
ALTER TABLE `systems` ADD FULLTEXT KEY `system_fulltext_name` (`name`);

--
-- Klíče pro tabulku `temp_table`
--
ALTER TABLE `temp_table` ADD FULLTEXT KEY `system_name` (`system_name`);

--
-- Klíče pro tabulku `types`
--
ALTER TABLE `types`
  ADD PRIMARY KEY (`id`);
ALTER TABLE `types` ADD FULLTEXT KEY `type_fulltext_index_name` (`name`);

--
-- AUTO_INCREMENT pro tabulky
--

--
-- AUTO_INCREMENT pro tabulku `allegiances`
--
ALTER TABLE `allegiances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pro tabulku `audit_table`
--
ALTER TABLE `audit_table`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT pro tabulku `planets`
--
ALTER TABLE `planets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT pro tabulku `powerplays`
--
ALTER TABLE `powerplays`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pro tabulku `services`
--
ALTER TABLE `services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT pro tabulku `stars`
--
ALTER TABLE `stars`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT pro tabulku `startypes`
--
ALTER TABLE `startypes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT pro tabulku `stations`
--
ALTER TABLE `stations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT pro tabulku `systems`
--
ALTER TABLE `systems`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT pro tabulku `types`
--
ALTER TABLE `types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Omezení pro exportované tabulky
--

--
-- Omezení pro tabulku `planets`
--
ALTER TABLE `planets`
  ADD CONSTRAINT `planets_ibfk_1` FOREIGN KEY (`system_id`) REFERENCES `systems` (`id`),
  ADD CONSTRAINT `planets_ibfk_3` FOREIGN KEY (`type_id`) REFERENCES `types` (`id`);

--
-- Omezení pro tabulku `stars`
--
ALTER TABLE `stars`
  ADD CONSTRAINT `stars_ibfk_1` FOREIGN KEY (`system_id`) REFERENCES `systems` (`id`),
  ADD CONSTRAINT `stars_ibfk_2` FOREIGN KEY (`starType_id`) REFERENCES `startypes` (`id`);

--
-- Omezení pro tabulku `stations`
--
ALTER TABLE `stations`
  ADD CONSTRAINT `stations_ibfk_1` FOREIGN KEY (`system_id`) REFERENCES `systems` (`id`),
  ADD CONSTRAINT `stations_ibfk_2` FOREIGN KEY (`planet_id`) REFERENCES `planets` (`id`),
  ADD CONSTRAINT `stations_ibfk_3` FOREIGN KEY (`allegiance_id`) REFERENCES `allegiances` (`id`),
  ADD CONSTRAINT `stations_ibfk_4` FOREIGN KEY (`maxPadSize_id`) REFERENCES `padsizes` (`id`);

--
-- Omezení pro tabulku `station_service`
--
ALTER TABLE `station_service`
  ADD CONSTRAINT `station_service_ibfk_1` FOREIGN KEY (`station_id`) REFERENCES `stations` (`id`),
  ADD CONSTRAINT `station_service_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`);

--
-- Omezení pro tabulku `systems`
--
ALTER TABLE `systems`
  ADD CONSTRAINT `systems_ibfk_1` FOREIGN KEY (`allegiance_id`) REFERENCES `allegiances` (`id`),
  ADD CONSTRAINT `systems_ibfk_2` FOREIGN KEY (`powerplay_id`) REFERENCES `powerplays` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
