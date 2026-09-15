-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Gép: mysql:3306
-- Létrehozás ideje: 2026. Aug 17. 17:51
-- Kiszolgáló verziója: 8.4.11
-- PHP verzió: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


-- USER TÁBLA + CRUD (Stored Procedures) HIBAKÓDOKKAL
-- MySQL / InnoDB
-- =====================================================================

-- ---------------------------------------------------------------------
-- HIBAKÓD-KONVENCIÓ (saját alkalmazási hibák, MYSQL_ERRNO mezővel)
-- ---------------------------------------------------------------------
-- 45001  - Hiányzó kötelező mező
-- 45002  - Username már foglalt
-- 45003  - Email már foglalt
-- 45004  - Felhasználó nem található (id alapján)
-- 45005  - Felhasználó már törölve van (soft delete)
-- 45006  - Érvénytelen email formátum
-- 45007  - Érvénytelen ID (pl. <= 0 vagy NULL)
-- 45008  - Nincs módosítandó mező megadva UPDATE-nél
-- Ezek mellett a natív MySQL hibák (pl. 1062 duplicate entry) is
-- előfordulhatnak, ha valaki nem a proceduren keresztül ír a táblába.
-- ---------------------------------------------------------------------


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `kelet_baranya_db`
--
CREATE DATABASE IF NOT EXISTS `kelet_baranya_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `kelet_baranya_db`;

DELIMITER $$

-- --------------------------------------------------------
--
-- Admin regisztráció és kapcsolódó eljárások
--
-- --------------------------------------------------------

--
-- Register Admin procedure
--

DROP PROCEDURE IF EXISTS `sp_adminInfo_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_adminInfo_create` (
    IN `p_user_id` INT,
    IN `p_admin_settings_id` INT,
    OUT `p_adminInfo_id` INT
)   BEGIN
    INSERT INTO `adminInfo`( `user_id`,  `admin_settings_id`) VALUES (p_user_id, p_admin_settings_id);

    SET p_adminInfo_id = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `sp_admin_register`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_admin_register` (IN `p_username` VARCHAR(25), IN `p_password_hash` VARCHAR(255), IN `p_email` VARCHAR(255))   BEGIN
    DECLARE v_user_id INT;
    DECLARE v_base_settings_id INT;
    DECLARE v_admin_settings_id INT;
    DECLARE v_adminInfo_id INT;

    -- Hibakezelő: ha a láncolt INSERT-ek bármelyike hibázik, minden eddigi
    -- változást visszavonjuk, hogy ne maradjon árva user/settings sor.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- JAVÍTVA: az ID-kat mostantól OUT paraméterekkel kapjuk vissza, nem
    -- LAST_INSERT_ID()-vel - így nem számít, mi történik a hívott procedure
    -- belsejében (pl. ha később egy plusz INSERT kerül bele), az érték
    -- mindig helyesen, közvetlenül a forrás-procedure-ből érkezik.
    call sp_user_create(p_username, p_password_hash, p_email, "admin", 0, v_user_id);
    call sp_base_settings_create(v_user_id, v_base_settings_id);
    call sp_admin_settings_create(v_base_settings_id, v_admin_settings_id);
    call sp_adminInfo_create(v_user_id, v_admin_settings_id, v_adminInfo_id);

    COMMIT;

    SELECT `id`, `username`, `password_hash`, `email`, `type`  FROM `user` WHERE id = v_user_id;
END$$

DROP PROCEDURE IF EXISTS `sp_admin_settings_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_admin_settings_create` (
    IN `p_base_settings_id` INT,
    OUT `p_admin_settings_id` INT
)   BEGIN
    INSERT INTO `admin_settings`(`settings_id`, `event_reminder`, `new_event_notification`) VALUES (p_base_settings_id, 0 , 0);

    SET p_admin_settings_id = LAST_INSERT_ID();
END$$


-- --------------------------------------------------------
--
-- User regisztráció és kapcsolódó eljárások
--
-- --------------------------------------------------------

--
-- Register User procedure
--
DROP PROCEDURE IF EXISTS `sp_user_register`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_register` (IN `p_username` VARCHAR(25), IN `p_password_hash` VARCHAR(255), IN `p_email` VARCHAR(255))   BEGIN
    DECLARE v_user_id INT;
    DECLARE v_base_settings_id INT;
    DECLARE v_user_settings_id INT;
    DECLARE v_userInfo_id INT;

    -- Hibakezelő: ha a láncolt INSERT-ek bármelyike hibázik, minden eddigi
    -- változást visszavonjuk, hogy ne maradjon árva user/settings sor.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- JAVÍTVA: az ID-kat mostantól OUT paraméterekkel kapjuk vissza, nem
    -- LAST_INSERT_ID()-vel - lásd megjegyzés az sp_admin_register-ben.
    call sp_user_create(p_username, p_password_hash, p_email, "user", "0", v_user_id);
    call sp_base_settings_create(v_user_id, v_base_settings_id);
    call sp_user_settings_create(v_base_settings_id, v_user_settings_id);
    call sp_userInfo_create(v_user_id, v_user_settings_id, v_userInfo_id);

    COMMIT;

    SELECT `id`, `username`, `password_hash`, `email`, `type`  FROM `user` WHERE id = v_user_id;
END$$


DROP PROCEDURE IF EXISTS `sp_user_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_create` (
    IN `p_username` VARCHAR(25), 
    IN `p_password_hash` VARCHAR(255), 
    IN `p_email` VARCHAR(255), 
    IN `p_type` VARCHAR(255), 
    in `p_two_factor_enabled` TINYINT(1),
    OUT `p_user_id` INT
)   BEGIN
    DECLARE v_exists_username INT DEFAULT 0;
    DECLARE v_exists_email    INT DEFAULT 0;

    -- HibakezelÅ‘: ha mÃ©gis lecsÃºszna egy duplikÃ¡ciÃ³ a race condition miatt
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        RESIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'AdatbÃ¡zis szintÅ± Ã¼tkÃ¶zÃ©s (duplikÃ¡lt username vagy email).',
                MYSQL_ERRNO  = 45009;
    END;



    -- KÃ¶telezÅ‘ mezÅ‘k ellenÅ‘rzÃ©se
    IF p_username IS NULL OR TRIM(p_username) = '' 
       OR p_password_hash IS NULL OR TRIM(p_password_hash) = ''
       OR p_email IS NULL OR TRIM(p_email) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'HiÃ¡nyzÃ³ kÃ¶telezÅ‘ mezÅ‘ (username, password_hash, email).',
                MYSQL_ERRNO  = 45001;
    END IF;

    -- EgyszerÅ± email formÃ¡tum ellenÅ‘rzÃ©s
    IF p_email NOT LIKE '_%@_%.__%' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ã‰rvÃ©nytelen email formÃ¡tum.',
                MYSQL_ERRNO  = 45006;
    END IF;

    -- Username egyedisÃ©g
    SELECT COUNT(*) INTO v_exists_username
    FROM `user`
    WHERE `username` = p_username;

    IF v_exists_username > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A megadott felhasznÃ¡lÃ³nÃ©v mÃ¡r foglalt.',
                MYSQL_ERRNO  = 45002;
    END IF;

    -- Email egyedisÃ©g
    SELECT COUNT(*) INTO v_exists_email
    FROM `user`
    WHERE `email` = p_email;

    IF v_exists_email > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A megadott email cÃ­m mÃ¡r foglalt.',
                MYSQL_ERRNO  = 45003;
    END IF;

    INSERT INTO `user` (`username`, `password_hash`, `email`, `type`, `two_factor_enabled`,`created_at`, `isDeleted`)
    VALUES (p_username, p_password_hash, p_email, p_type, p_two_factor_enabled, NOW(), 0);

    SET p_user_id = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `sp_base_settings_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_base_settings_create` (
    IN `p_user_id` INT(11),
    OUT `p_base_settings_id` INT
)   BEGIN
    INSERT INTO `base_settings`
        (`id`, `language`, `unit_system`, `push_notification`, `email_notification`, `dark_mode`)
    VALUES
        (p_user_id, 'en', 'metric', 0, 0, 0);

    -- Megjegyzés: a base_settings.id SZÁNDÉKOSAN megegyezik a user.id-val
    SET p_base_settings_id = p_user_id;
END$$


DROP PROCEDURE IF EXISTS `sp_user_settings_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_settings_create` (
    IN `p_base_settings_id` INT(11),
    OUT `p_user_settings_id` INT
)   BEGIN
    INSERT INTO `user_settings`(`settings_id`, `event_reminder`, `new_event_notification`) VALUES (p_base_settings_id, 0 , 0);

    SET p_user_settings_id = LAST_INSERT_ID();
END$$


DROP PROCEDURE IF EXISTS `sp_userInfo_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_userInfo_create` (
    IN `p_user_id` INT(11),
    IN `p_user_settings_id` INT(11),
    OUT `p_userInfo_id` INT
)   BEGIN
    INSERT INTO `userInfo`( `user_id`,  `user_settings_id`) VALUES (p_user_id, p_user_settings_id);

    SET p_userInfo_id = LAST_INSERT_ID();
END$$


-- --------------------------------------------------------
--
-- Organizer regisztráció és kapcsolódó eljárások
--
-- --------------------------------------------------------

--
-- Register organizer procedure
--
DROP PROCEDURE IF EXISTS `sp_organizer_register`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_organizer_register` (
    IN `p_username` VARCHAR(25), 
    IN `p_password_hash` VARCHAR(255), 
    IN `p_email` VARCHAR(255),
    IN `p_fullname` VARCHAR(64),
    in `p_two_factor_enabled` TINYINT(1)
)   BEGIN
    DECLARE v_user_id INT;
    DECLARE v_base_settings_id INT;
    DECLARE v_organizer_settings_id INT;
    DECLARE v_organizerInfo_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    call sp_user_create(p_username, p_password_hash, p_email, "organizer", p_two_factor_enabled, v_user_id);
    call sp_base_settings_create(v_user_id, v_base_settings_id);
    call sp_organizer_settings_create(v_base_settings_id, v_organizer_settings_id);
    call sp_organizerInfo_create(v_user_id, v_organizer_settings_id, p_fullname, v_organizerInfo_id);

    COMMIT;

    SELECT `id`, `username`, `password_hash`, `email`, `type`  FROM `user` WHERE id = v_user_id;
END$$

DROP PROCEDURE IF EXISTS `sp_organizer_settings_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_organizer_settings_create` (
    IN `p_base_settings_id` INT(11),
    OUT `p_organizer_settings_id` INT
)   BEGIN
    INSERT INTO `organizer_settings`(`settings_id`, `event_approved_notification`) VALUES (p_base_settings_id, 0);

    SET p_organizer_settings_id = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `sp_organizerInfo_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_organizerInfo_create` (
    IN `p_user_id` INT,
    IN `p_organizer_settings_id` INT,
    IN `p_fullname` VARCHAR(64),
    OUT `p_organizerInfo_id` INT
)   BEGIN
    INSERT INTO `organizerInfo`( `user_id`,  `organizer_settings_id`, `fullname`) VALUES (p_user_id, p_organizer_settings_id, p_fullname);

    SET p_organizerInfo_id = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `sp_organizer_get_by_id`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_organizer_get_by_id`(
    IN `p_user_id` BIGINT
)
BEGIN
    DECLARE v_email_verified TINYINT DEFAULT NULL;
    DECLARE v_user_type VARCHAR(255) DEFAULT NULL;

    SELECT 
        email_verified,
        type
    INTO 
        v_email_verified,
        v_user_type
    FROM `user`
    WHERE id = p_user_id
    LIMIT 1;

    IF v_email_verified IS NULL THEN

        SELECT 
            0 AS success,
            'A felhasználó nem található.' AS message;

    ELSEIF v_email_verified = 0 THEN

        SELECT 
            0 AS success,
            'A felhasználó nem erősítette meg az email címét.' AS message;

    ELSEIF v_user_type <> 'organizer' THEN

        SELECT 
            0 AS success,
            'A felhasználó nem organizer típusú.' AS message;

    ELSE

        SELECT
            1 AS success,

            u.id AS user_id,
            u.username,
            u.email,
            u.type,
            u.email_verified,

            oi.id AS organizer_info_id,
            oi.fullname,
            oi.image_id,
            oi.bio,
            oi.rating,
            oi.organizer_settings_id,

            os.id AS organizer_settings_id,
            os.settings_id,
            os.event_approved_notification,

            bs.id AS base_settings_id,
            bs.language,
            bs.unit_system,
            bs.push_notification,
            bs.email_notification,
            bs.dark_mode

        FROM `user` u

        LEFT JOIN `organizerInfo` oi
            ON oi.user_id = u.id

        LEFT JOIN `organizer_settings` os
            ON os.id = oi.organizer_settings_id

        LEFT JOIN `base_settings` bs
            ON bs.id = os.settings_id

        WHERE u.id = p_user_id;

    END IF;

END$$


-- --------------------------------------------------------
--
-- Bejelentkezés (Login)
--
-- --------------------------------------------------------

--
-- Login user procedure
--
DROP PROCEDURE IF EXISTS `sp_user_login`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_login` (
    IN sp_login_identifiry VARCHAR(255),
    IN sp_user_role VARCHAR(255)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    -- Üres/null login azonosító ellenőrzése
    IF sp_login_identifiry IS NULL OR TRIM(sp_login_identifiry) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A bejelentkezési azonosító nem lehet üres.',
                MYSQL_ERRNO = 45007;
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM `user`
    WHERE `email` = sp_login_identifiry
       OR `username` = sp_login_identifiry;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasználó nem található.',
                MYSQL_ERRNO = 45004;
    END IF;

    IF sp_user_role = '*' THEN
        SELECT
            `id`,
            `username`,
            `email`,
            `password_hash`,
            `email_verified`,
            `two_factor_enabled`,
            `type`
        FROM `user`
        WHERE `email` = sp_login_identifiry
           OR `username` = sp_login_identifiry;
    ELSE

        SELECT
            `id`,
            `username`,
            `email`,
            `password_hash`,
            `email_verified`,
            `two_factor_enabled`,
            `type`
        FROM `user`
        WHERE (`email` = sp_login_identifiry AND `type` = sp_user_role)
           OR (`username` = sp_login_identifiry AND `type` = sp_user_role);
    END IF;

END$$




-- --------------------------------------------------------
--
-- Refresh token eljárások
--
-- --------------------------------------------------------

--
-- Refresh token procedures
--
DROP PROCEDURE IF EXISTS `sp_refresh_token_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_refresh_token_create` (IN `p_user_id` INT(11), IN `p_token` VARCHAR(255), IN `p_user_agent` TEXT, IN `p_accept_language` VARCHAR(255), IN `p_sec_ch_ua` TEXT, IN `p_sec_ch_ua_mobile` VARCHAR(20), IN `p_sec_ch_ua_platform` VARCHAR(50), IN `p_expires_at` DATETIME)   BEGIN
    DECLARE v_refresh_token_id INT;

    INSERT INTO `refresh_token` (
        `user_id`,
        `token`,
        `user_agent`,
        `accept_language`,
        `sec_ch_ua`,
        `sec_ch_ua_mobile`,
        `sec_ch_ua_platform`,
        `expires_at`
    )
    VALUES (
        p_user_id,
        p_token,
        p_user_agent,
        p_accept_language,
        p_sec_ch_ua,
        p_sec_ch_ua_mobile,
        p_sec_ch_ua_platform,
        p_expires_at
    );

    SET v_refresh_token_id = LAST_INSERT_ID();

    SELECT v_refresh_token_id AS refresh_token_id;
END$$


-- --------------------------------------------------------
--
-- User token eljárások
--
-- --------------------------------------------------------

DROP PROCEDURE IF EXISTS `sp_user_token_get_user`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_token_get_user`(
    IN p_token VARCHAR(255)
)
BEGIN
    SELECT ut.*
    FROM user_token ut
    INNER JOIN user u ON u.id = ut.user_id
    WHERE ut.token = p_token
      AND u.type = 'user'
    LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `sp_user_token_get_organizer`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_token_get_organizer`(
    IN p_token VARCHAR(255)
)
BEGIN
    SELECT ut.*
    FROM user_token ut
    INNER JOIN user u ON u.id = ut.user_id
    WHERE ut.token = p_token
      AND u.type = 'organizer'
    LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `sp_refresh_token_revoke` $$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_refresh_token_revoke` (
    IN p_token VARCHAR(500)
)
BEGIN
    UPDATE `refresh_token`
    SET `revoked_at` = CURRENT_TIMESTAMP()
    WHERE `token` = p_token
      AND `revoked_at` IS NULL;
END $$

--
-- user token proceduras
--

DROP PROCEDURE IF EXISTS `sp_user_token_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_token_create`(
    IN p_user_id INT,
    IN p_token VARCHAR(255),
    IN p_type VARCHAR(255),
    IN p_expires_at DATETIME
)
BEGIN
    DELETE FROM user_token WHERE user_id = p_user_id;
 
    INSERT INTO user_token (user_id, token, token_type,expires_at)
    VALUES (p_user_id, p_token, p_type, p_expires_at);
END$$

DROP PROCEDURE IF EXISTS `sp_user_token_get`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_token_get`(
    IN p_token VARCHAR(255)
)
BEGIN
    SELECT * FROM user_token 
    WHERE token = p_token
    LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `sp_user_token_delete`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_token_delete`(
    IN p_token VARCHAR(255)
)
BEGIN
    DELETE FROM user_token WHERE token = p_token;
END$$


-- --------------------------------------------------------
--
-- User lekérdezés és módosítás
--
-- --------------------------------------------------------

--
-- Get user by Id
--
DROP PROCEDURE IF EXISTS `sp_user_get_by_id`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_get_by_id` (IN `p_user_id` BIGINT)   BEGIN
    DECLARE v_email_verified TINYINT DEFAULT NULL;

    SELECT email_verified
    INTO v_email_verified
    FROM `user`
    WHERE id = p_user_id
    LIMIT 1;

    IF v_email_verified IS NULL THEN

        SELECT
            0 AS success,
            'A felhasznÃ¡lÃ³ nem talÃ¡lhatÃ³.' AS message;

    ELSEIF v_email_verified = 0 THEN

        SELECT
            0 AS success,
            'A felhasznÃ¡lÃ³ nem erÅ‘sÃ­tette meg az email cÃ­mÃ©t.' AS message;

    ELSE

        SELECT
            1 AS success,
            u.id AS user_id,
            u.username,
            u.email,
            u.type,
            u.email_verified,

            ui.id AS user_info_id,
            ui.image_id,
            ui.user_settings_id,

            us.id AS user_settings_id,
            us.settings_id,
            us.event_reminder,
            us.new_event_notification,

            bs.id AS base_settings_id,
            bs.language,
            bs.unit_system,
            bs.push_notification,
            bs.email_notification,
            bs.dark_mode

        FROM `user` u

        LEFT JOIN `userInfo` ui
            ON ui.user_id = u.id

        LEFT JOIN `user_settings` us
            ON us.id = ui.user_settings_id

        LEFT JOIN `base_settings` bs
            ON bs.id = us.settings_id

        WHERE u.id = p_user_id;

    END IF;

END$$

--
-- user password update by id
--

DROP PROCEDURE IF EXISTS `sp_user_update_password`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_update_password`(
    IN p_user_id INT,
    IN p_password_hash VARCHAR(255)
)
BEGIN
    UPDATE user SET password_hash = p_password_hash WHERE id = p_user_id;
END$$

--
-- sp_user_confirm_email
--
DROP PROCEDURE IF EXISTS `sp_user_confirm_email`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_confirm_email`(IN `p_user_id` INT)
BEGIN
    UPDATE `user` SET `email_verified` = 1 WHERE `id` = `p_user_id`;
END$$

DROP PROCEDURE IF EXISTS sp_user_set_two_factor $$
CREATE DEFINER=`root`@`%` PROCEDURE sp_user_set_two_factor(
    IN p_user_id INT,
    IN p_enabled TINYINT(1)
)
BEGIN
    UPDATE user
    SET two_factor_enabled = p_enabled
    WHERE id = p_user_id;
 
    SELECT p_user_id AS id, p_enabled AS two_factor_enabled;
END $$


-- --------------------------------------------------------
--
-- Location
--
-- --------------------------------------------------------

--
-- sp_location_create
--
DROP PROCEDURE IF EXISTS `sp_location_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_location_create` (
    IN `p_name` VARCHAR(50),
    IN `p_address` VARCHAR(255),
    IN `p_description` TEXT,
    IN `p_group_id` INT,
    IN `p_created_by_user_id` INT,
    OUT `p_location_id` INT
)
BEGIN
    INSERT INTO `location` (`name`, `address`, `description`, `group_id`, `created_by_user_id`)
    VALUES (p_name, p_address, p_description, p_group_id, p_created_by_user_id);

    SET p_location_id = LAST_INSERT_ID();
END$$

--
-- sp_location_get_by_id
--
DROP PROCEDURE IF EXISTS `sp_location_get_by_id`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_location_get_by_id` (
    IN `p_location_id` INT
)
BEGIN
    SELECT
        `id`,
        `name`,
        `address`,
        `description`,
        `rating`,
        `group_id`,
        `created_by_user_id`,
        `approved_status`,
        `created_at`,
        `updated_at`
    FROM `location`
    WHERE `id` = p_location_id;
END$$

--
-- sp_location_list
--
DROP PROCEDURE IF EXISTS `sp_location_list`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_location_list` (
    IN `p_approved_status` ENUM('all','pending','approved','denied'),
    IN `p_limit` INT,
    IN `p_offset` INT
)
BEGIN
    SELECT
        `id`,
        `name`,
        `address`,
        `rating`,
        `group_id`,
        `created_by_user_id`,
        `approved_status`,
        `created_at`
    FROM `location`
    WHERE `isDeleted` = 0
      AND (p_approved_status = 'all' OR p_approved_status IS NULL OR `approved_status` = p_approved_status)
    ORDER BY `created_at` DESC
    LIMIT p_limit OFFSET p_offset;
END$$

--
-- sp_location_update
--
DROP PROCEDURE IF EXISTS `sp_location_update`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_location_update` (
    IN `p_location_id` INT,
    IN `p_name` VARCHAR(50),
    IN `p_address` VARCHAR(255),
    IN `p_description` TEXT,
    IN `p_group_id` INT
)
BEGIN
    UPDATE `location`
    SET `name` = p_name,
        `address` = p_address,
        `description` = p_description,
        `group_id` = p_group_id,
        `updated_at` = NOW()
    WHERE `id` = p_location_id;
END$$

--
-- sp_location_soft_delete
--
DROP PROCEDURE IF EXISTS `sp_location_soft_delete`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_location_soft_delete` (
    IN `p_location_id` INT
)
BEGIN
    UPDATE `location`
    SET `isDeleted` = 1,
        `deleted_at` = NOW()
    WHERE `id` = p_location_id;
END$$

--
-- sp_location_restore
--
DROP PROCEDURE IF EXISTS `sp_location_restore`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_location_restore` (
    IN `p_location_id` INT
)
BEGIN
    UPDATE `location`
    SET `isDeleted` = 0,
        `deleted_at` = NULL
    WHERE `id` = p_location_id;
END$$

--
-- sp_location_set_approved_status
--
DROP PROCEDURE IF EXISTS `sp_location_set_approved_status`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_location_set_approved_status` (
    IN `p_location_id` INT,
    IN `p_approved_status` ENUM('pending','approved','denied')
)
BEGIN
    UPDATE `location`
    SET `approved_status` = p_approved_status,
        `updated_at` = NOW()
    WHERE `id` = p_location_id;
END$$


-- --------------------------------------------------------
--
-- Event
--
-- --------------------------------------------------------

--
-- sp_event_create
--
DROP PROCEDURE IF EXISTS `sp_event_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_event_create` (
    IN `p_title` VARCHAR(75),
    IN `p_location_id` INT,
    IN `p_start_time` DATETIME,
    IN `p_end_time` DATETIME,
    IN `p_description` TEXT,
    IN `p_group_id` INT,
    IN `p_max_participants` INT,
    IN `p_created_by_user_id` INT,
    OUT `p_event_id` INT
)
BEGIN
    INSERT INTO `event` (`title`, `location_id`, `start_time`, `end_time`, `description`, `group_id`, `max_participants`, `created_by_user_id`)
    VALUES (p_title, p_location_id, p_start_time, p_end_time, p_description, p_group_id, p_max_participants, p_created_by_user_id);

    SET p_event_id = LAST_INSERT_ID();
END$$

--
-- sp_event_get_by_id
--
DROP PROCEDURE IF EXISTS `sp_event_get_by_id`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_event_get_by_id` (
    IN `p_event_id` INT
)
BEGIN
    SELECT
        `id`,
        `title`,
        `location_id`,
        `start_time`,
        `end_time`,
        `description`,
        `group_id`,
        `max_participants`,
        `rating`,
        `repeat_id`,
        `approved_status`,
        `created_by_user_id`,
        `created_at`,
        `updated_at`
    FROM `event`
    WHERE `id` = p_event_id;
END$$

--
-- sp_event_list
--
DROP PROCEDURE IF EXISTS `sp_event_list`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_event_list` (
    IN `p_approved_status` ENUM('all','pending','approved','denied'),
    IN `p_location_id` INT,
    IN `p_limit` INT,
    IN `p_offset` INT
)
BEGIN
    SELECT
        `id`,
        `title`,
        `location_id`,
        `start_time`,
        `end_time`,
        `group_id`,
        `max_participants`,
        `rating`,
        `approved_status`,
        `created_by_user_id`,
        `created_at`
    FROM `event`
    WHERE `isDeleted` = 0
      AND (p_approved_status = 'all' OR p_approved_status IS NULL OR `approved_status` = p_approved_status)
      AND (p_location_id IS NULL OR `location_id` = p_location_id)
    ORDER BY `start_time` ASC
    LIMIT p_limit OFFSET p_offset;
END$$

--
-- sp_event_update
--
DROP PROCEDURE IF EXISTS `sp_event_update`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_event_update` (
    IN `p_event_id` INT,
    IN `p_title` VARCHAR(75),
    IN `p_location_id` INT,
    IN `p_start_time` DATETIME,
    IN `p_end_time` DATETIME,
    IN `p_description` TEXT,
    IN `p_group_id` INT,
    IN `p_max_participants` INT
)
BEGIN
    UPDATE `event`
    SET `title` = p_title,
        `location_id` = p_location_id,
        `start_time` = p_start_time,
        `end_time` = p_end_time,
        `description` = p_description,
        `group_id` = p_group_id,
        `max_participants` = p_max_participants,
        `updated_at` = NOW()
    WHERE `id` = p_event_id;
END$$

--
-- sp_event_soft_delete
--
DROP PROCEDURE IF EXISTS `sp_event_soft_delete`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_event_soft_delete` (
    IN `p_event_id` INT
)
BEGIN
    UPDATE `event`
    SET `isDeleted` = 1,
        `deleted_at` = NOW()
    WHERE `id` = p_event_id;
END$$

--
-- sp_event_restore
--
DROP PROCEDURE IF EXISTS `sp_event_restore`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_event_restore` (
    IN `p_event_id` INT
)
BEGIN
    UPDATE `event`
    SET `isDeleted` = 0,
        `deleted_at` = NULL
    WHERE `id` = p_event_id;
END$$

--
-- sp_event_set_approved_status
--
DROP PROCEDURE IF EXISTS `sp_event_set_approved_status`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_event_set_approved_status` (
    IN `p_event_id` INT,
    IN `p_approved_status` ENUM('pending','approved','denied')
)
BEGIN
    UPDATE `event`
    SET `approved_status` = p_approved_status,
        `updated_at` = NOW()
    WHERE `id` = p_event_id;
END$$


DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
