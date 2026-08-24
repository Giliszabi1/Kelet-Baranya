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
--
-- Eljárások
--
--
-- Register Admin procedure
--

DROP PROCEDURE IF EXISTS `sp_adminInfo_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_adminInfo_create` (IN `p_user_id` INT, IN `p_admin_settings_id` INT)   BEGIN
    DECLARE v_adminInfo_id INT;

    INSERT INTO `adminInfo`( `user_id`,  `admin_settings_id`) VALUES (p_user_id, p_admin_settings_id);

    SET v_adminInfo_id = LAST_INSERT_ID();

    SELECT v_adminInfo_id AS adminInfo_id;
END$$

DROP PROCEDURE IF EXISTS `sp_admin_register`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_admin_register` (IN `p_username` VARCHAR(25), IN `p_password_hash` VARCHAR(255), IN `p_email` VARCHAR(255))   BEGIN
    DECLARE v_user_id INT;
    DECLARE v_base_settings_id INT;
    DECLARE v_admin_settings_id INT;

    call sp_user_create(p_username, p_password_hash, p_email, "user");
    SET v_user_id = LAST_INSERT_ID();

    call sp_base_settings_create(v_user_id);
    SET v_base_settings_id = LAST_INSERT_ID();

    call sp_admin_settings_create(v_base_settings_id);
    SET v_admin_settings_id = LAST_INSERT_ID();

    call sp_adminInfo_create(v_user_id, v_admin_settings_id);
    
    SELECT `id`, `username`, `password_hash`, `email`, `type`  FROM `user` WHERE id = v_user_id;
END$$

DROP PROCEDURE IF EXISTS `sp_admin_settings_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_admin_settings_create` (IN `p_base_settings_id` INT)   BEGIN
    DECLARE v_admin_settings_id INT;

    INSERT INTO `admin_settings`(`settings_id`, `event_reminder`, `new_event_notification`) VALUES (p_base_settings_id, 0 , 0);

    SET v_admin_settings_id = LAST_INSERT_ID();

    SELECT v_admin_settings_id AS admin_settings_id;
END$$

--
-- Register User procedure
--
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_register` (IN `p_username` VARCHAR(25), IN `p_password_hash` VARCHAR(255), IN `p_email` VARCHAR(255))   BEGIN
    DECLARE v_user_id INT;
    DECLARE v_base_settings_id INT;
    DECLARE v_user_settings_id INT;

    call sp_user_create(p_username, p_password_hash, p_email, "user", "0");
    SET v_user_id = LAST_INSERT_ID();

    call sp_base_settings_create(v_user_id);
    SET v_base_settings_id = LAST_INSERT_ID();

    call sp_user_settings_create(v_base_settings_id);
    SET v_user_settings_id = LAST_INSERT_ID();

    call sp_userInfo_create(v_user_id, v_user_settings_id);
    
    SELECT `id`, `username`, `password_hash`, `email`, `type`  FROM `user` WHERE id = v_user_id;
END$$


DROP PROCEDURE IF EXISTS `sp_user_create`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_create` (
    IN `p_username` VARCHAR(25), 
    IN `p_password_hash` VARCHAR(255), 
    IN `p_email` VARCHAR(255), 
    IN `p_type` VARCHAR(255), 
    in `p_two_factor_enabled` TINYINT(1)
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

    SELECT `id`, `username`, `password_hash`, `email`, `type` FROM `user` WHERE id = LAST_INSERT_ID();
END$$

DROP PROCEDURE IF EXISTS `sp_base_settings_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_base_settings_create` (IN `p_user_id` INT(11))   BEGIN
    DECLARE v_base_settings_id INT;

    INSERT INTO `base_settings`
        (`id`, `language`, `unit_system`, `push_notification`, `email_notification`, `dark_mode`)
    VALUES
        (p_user_id, 'en', 'metric', 0, 0, 0);

    SET v_base_settings_id = p_user_id;

    SELECT v_base_settings_id AS base_settings_id;
END$$


DROP PROCEDURE IF EXISTS `sp_user_settings_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_settings_create` (IN `p_base_settings_id` INT(11))   BEGIN
    DECLARE v_user_settings_id INT;

    INSERT INTO `user_settings`(`settings_id`, `event_reminder`, `new_event_notification`) VALUES (p_base_settings_id, 0 , 0);

    SET v_user_settings_id = LAST_INSERT_ID();

    SELECT v_user_settings_id AS user_settings_id;
END$$


DROP PROCEDURE IF EXISTS `sp_userInfo_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_userInfo_create` (IN `p_user_id` INT(11), IN `p_user_settings_id` INT(11))   BEGIN
    DECLARE v_userInfo_id INT;

    INSERT INTO `userInfo`( `user_id`,  `user_settings_id`) VALUES (p_user_id, p_user_settings_id);

    SET v_userInfo_id = LAST_INSERT_ID();

    SELECT v_userInfo_id AS userInfo_id;
END$$


--
-- Register organizer procedure
--
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

    call sp_user_create(p_username, p_password_hash, p_email, "organizer", p_two_factor_enabled);
    SET v_user_id = LAST_INSERT_ID();

    call sp_base_settings_create(v_user_id);
    SET v_base_settings_id = LAST_INSERT_ID();

    call sp_organizer_settings_create(v_base_settings_id);
    SET v_organizer_settings_id = LAST_INSERT_ID();

    call sp_organizerInfo_create(v_user_id, v_organizer_settings_id, p_fullname);
    
    SELECT `id`, `username`, `password_hash`, `email`, `type`  FROM `user` WHERE id = v_user_id;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_organizer_settings_create` (IN `p_base_settings_id` INT(11))   BEGIN
    DECLARE v_organizer_settings_id INT;

    INSERT INTO `organizer_settings`(`settings_id`, `event_approved_notification`) VALUES (p_base_settings_id, 0);

    SET v_organizer_settings_id = LAST_INSERT_ID();

    SELECT v_organizer_settings_id AS organizer_settings_id;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_organizerInfo_create` (IN `p_user_id` INT, IN `p_organizer_settings_id` INT, IN `p_fullname` VARCHAR(64))   BEGIN
    DECLARE v_organizerInfo_id INT;

    INSERT INTO `organizerInfo`( `user_id`,  `organizer_settings_id`, `fullname`) VALUES (p_user_id, p_organizer_settings_id, p_fullname);

    SET v_organizerInfo_id = LAST_INSERT_ID();

    SELECT v_organizerInfo_id AS organizerInfo_id;
END$$

DROP PROCEDURE IF EXISTS `sp_organizer_get_by_id`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_organizer_get_by_id`(
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


--
-- Login user procedure
--
DROP PROCEDURE IF EXISTS `sp_user_login` $$
CREATE PROCEDURE `sp_user_login` (
    IN sp_login_identifiry VARCHAR(255),
    In sp_user_role VARCHAR(255)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    -- Üres/null login azonosító ellenőrzése
    IF sp_login_identifiry IS NULL OR TRIM(sp_login_identifiry) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A bejelentkezési azonosító nem lehet üres.',
                MYSQL_ERRNO = 45007;
    END IF;

    -- Felhasználó keresése email vagy username alapján
    SELECT COUNT(*)
    INTO v_count
    FROM `user`
    WHERE `email` = sp_login_identifiry
       OR `username` = sp_login_identifiry;

    -- Ha nincs találat
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasználó nem található.',
                MYSQL_ERRNO = 45004;
    END IF;

    if sp_user_role = "*" THEN
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
    END IF;

    -- Felhasználó visszaadása
    SELECT
        `id`,
        `username`,
        `email`,
        `password_hash`,
        `email_verified`,
        `two_factor_enabled`,
        `type`
    FROM `user`
    WHERE `email` = sp_login_identifiry AND `type`= sp_user_role
       OR `username` = sp_login_identifiry AND `type`= sp_user_role;

END $$




--
-- Refresh token procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_refresh_token_create` (IN `p_user_id` INT(11), IN `p_token` VARCHAR(255), IN `p_user_agent` TEXT, IN `p_accept_language` VARCHAR(255), IN `p_sec_ch_ua` TEXT, IN `p_sec_ch_ua_mobile` VARCHAR(20), IN `p_sec_ch_ua_platform` VARCHAR(50), IN `p_expires_at` DATETIME)   BEGIN
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


DROP PROCEDURE IF EXISTS `sp_user_token_get_user`$$
CREATE PROCEDURE `sp_user_token_get_user`(
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
CREATE PROCEDURE `sp_user_token_get_organizer`(
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
CREATE PROCEDURE `sp_refresh_token_revoke` (
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
CREATE PROCEDURE `sp_user_token_create`(
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
CREATE PROCEDURE `sp_user_token_get`(
    IN p_token VARCHAR(255)
)
BEGIN
    SELECT * FROM user_token 
    WHERE token = p_token
    LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `sp_user_token_delete`$$
CREATE PROCEDURE `sp_user_token_delete`(
    IN p_token VARCHAR(255)
)
BEGIN
    DELETE FROM user_token WHERE token = p_token;
END$$


--
-- Get user by Id
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_get_by_id` (IN `p_user_id` BIGINT)   BEGIN
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
-- user password update by id
DROP PROCEDURE IF EXISTS `sp_user_update_password`$$
CREATE PROCEDURE `sp_user_update_password`(
    IN p_user_id INT,
    IN p_password_hash VARCHAR(255)
)
BEGIN
    UPDATE user SET password_hash = p_password_hash WHERE id = p_user_id;
END$$

--
-- sp_user_confirm_email
--
DROP PROCEDURE IF EXISTS `sp_user_confirm_email`;
CREATE PROCEDURE `sp_user_confirm_email`(IN `p_user_id` INT)
BEGIN
    UPDATE `user` SET `email_verified` = 1 WHERE `id` = `p_user_id`;
END$$

DROP PROCEDURE IF EXISTS sp_user_set_two_factor $$
CREATE PROCEDURE sp_user_set_two_factor(
    IN p_user_id INT,
    IN p_enabled TINYINT(1)
)
BEGIN
    UPDATE user
    SET two_factor_enabled = p_enabled
    WHERE id = p_user_id;
 
    SELECT p_user_id AS id, p_enabled AS two_factor_enabled;
END $$


DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
