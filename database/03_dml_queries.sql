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
CREATE DEFINER=`root`@`%` PROCEDURE `sp_base_settings_create` (IN `p_user_id` INT(11))   BEGIN
    DECLARE v_base_settings_id INT;

    INSERT INTO `base_settings`
        (`id`, `language`, `unit_system`, `push_notification`, `email_notification`, `dark_mode`)
    VALUES
        (p_user_id, 'en', 'metric', 0, 0, 0);

    SET v_base_settings_id = p_user_id;

    SELECT v_base_settings_id AS base_settings_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_all_data` ()   BEGIN
    SET FOREIGN_KEY_CHECKS = 0;

    DELETE FROM `adminInfo`;
    DELETE FROM `admin_settings`;

    DELETE FROM `event_category`;
    DELETE FROM `event_image`;
    DELETE FROM `event_participant`;
    DELETE FROM `event_review`;
    DELETE FROM `user_favourite_event`;

    DELETE FROM `event_repeat`;
    DELETE FROM `event`;

    DELETE FROM `location_category`;
    DELETE FROM `location_image`;
    DELETE FROM `location_review`;
    DELETE FROM `user_favourite_location`;

    DELETE FROM `location`;

    DELETE FROM `group_member`;
    DELETE FROM `group`;

    DELETE FROM `organizer_review`;
    DELETE FROM `organizerInfo`;
    DELETE FROM `organizer_settings`;

    DELETE FROM `userInfo`;
    DELETE FROM `user_settings`;
    DELETE FROM `base_settings`;

    DELETE FROM `friend_request`;

    DELETE FROM `refresh_token`;
    DELETE FROM `user_token`;

    DELETE FROM `category`;
    DELETE FROM `image`;

    DELETE FROM `current_weather`;
    DELETE FROM `forecast_weather`;

    DELETE FROM `user`;

    ALTER TABLE `adminInfo` AUTO_INCREMENT = 1;
    ALTER TABLE `admin_settings` AUTO_INCREMENT = 1;
    ALTER TABLE `base_settings` AUTO_INCREMENT = 1;
    ALTER TABLE `category` AUTO_INCREMENT = 1;
    ALTER TABLE `current_weather` AUTO_INCREMENT = 1;
    ALTER TABLE `event` AUTO_INCREMENT = 1;
    ALTER TABLE `event_category` AUTO_INCREMENT = 1;
    ALTER TABLE `event_image` AUTO_INCREMENT = 1;
    ALTER TABLE `event_participant` AUTO_INCREMENT = 1;
    ALTER TABLE `event_repeat` AUTO_INCREMENT = 1;
    ALTER TABLE `event_review` AUTO_INCREMENT = 1;
    ALTER TABLE `forecast_weather` AUTO_INCREMENT = 1;
    ALTER TABLE `friend_request` AUTO_INCREMENT = 1;
    ALTER TABLE `group` AUTO_INCREMENT = 1;
    ALTER TABLE `group_member` AUTO_INCREMENT = 1;
    ALTER TABLE `image` AUTO_INCREMENT = 1;
    ALTER TABLE `location` AUTO_INCREMENT = 1;
    ALTER TABLE `location_category` AUTO_INCREMENT = 1;
    ALTER TABLE `location_image` AUTO_INCREMENT = 1;
    ALTER TABLE `location_review` AUTO_INCREMENT = 1;
    ALTER TABLE `organizerInfo` AUTO_INCREMENT = 1;
    ALTER TABLE `organizer_review` AUTO_INCREMENT = 1;
    ALTER TABLE `organizer_settings` AUTO_INCREMENT = 1;
    ALTER TABLE `user` AUTO_INCREMENT = 1;
    ALTER TABLE `userInfo` AUTO_INCREMENT = 1;
    ALTER TABLE `user_favourite_event` AUTO_INCREMENT = 1;
    ALTER TABLE `user_favourite_location` AUTO_INCREMENT = 1;
    ALTER TABLE `user_settings` AUTO_INCREMENT = 1;
    ALTER TABLE `refresh_token` AUTO_INCREMENT = 1;
    ALTER TABLE `user_token` AUTO_INCREMENT = 1;

    SET FOREIGN_KEY_CHECKS = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_event_create` (IN `p_title` VARCHAR(75), IN `p_location_id` INT, IN `p_start_time` DATETIME, IN `p_end_time` DATETIME, IN `p_description` TEXT, IN `p_group_id` INT, IN `p_max_participants` INT, IN `p_rating` DECIMAL(2,1), IN `p_repeat_id` INT, IN `p_approved_status` ENUM("pending","approved","denied"), IN `p_created_by_user_id` INT, OUT `p_new_id` INT)   BEGIN
INSERT INTO `event`(`title`, `location_id`, `start_time`, `end_time`, `description`, `group_id`, `max_participants`, `rating`, `repeat_id`, `approved_status`, `created_by_user_id`, `created_at`, `isDeleted`)
 VALUES ('p_title','p_location_id','p_start_time','p_end_time','p_description','p_group_id','p_max_participants','p_rating','p_repeat_id','p_approved_status','p_created_by_user_id', NOW(),'0');

    SET p_new_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_event_get_by_id` (IN `p_id` INT)   BEGIN
    SELECT `id`, `title`, `location_id`, `start_time`, `end_time`, `description`, `group_id`, `max_participants`, `rating`, `repeat_id`, `approved_status`, `created_by_user_id`, `created_at`, `updated_at`
    FROM `user`
    WHERE id = p_id
      AND isDeleted = 0;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_organizerInfo_create` (IN `p_user_id` INT, IN `p_organizer_settings_id` INT)   BEGIN
    DECLARE v_organizerInfo_id INT;

    INSERT INTO `organizerInfo`( `user_id`,  `organizer_settings_id`) VALUES (p_user_id, p_organizer_settings_id);

    SET v_organizerInfo_id = LAST_INSERT_ID();

    SELECT v_organizerInfo_id AS organizerInfo_id;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_organizer_register` (IN `p_username` INT, IN `p_password_hash` INT, IN `p_email` INT)   BEGIN
    DECLARE v_user_id INT;
    DECLARE v_base_settings_id INT;
    DECLARE v_organizer_settings_id INT;

    call sp_user_create(p_username, p_password_hash, p_email, "user");
    SET v_user_id = LAST_INSERT_ID();

    call sp_base_settings_create(v_user_id);
    SET v_base_settings_id = LAST_INSERT_ID();

    call sp_organizer_settings_create(v_base_settings_id);
    SET v_organizer_settings_id = LAST_INSERT_ID();

    call sp_organizerInfo_create(v_user_id, v_organizer_settings_id);
    
    SELECT `id`, `username`, `password_hash`, `email`, `type`  FROM `user` WHERE id = v_user_id;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_organizer_settings_create` (IN `p_base_settings_id` INT(11))   BEGIN
    DECLARE v_organizer_settings_id INT;

    INSERT INTO `organizer_settings`(`settings_id`, `event_approved_notification`) VALUES (p_base_settings_id, 0);

    SET v_organizer_settings_id = LAST_INSERT_ID();

    SELECT v_organizer_settings_id AS organizer_settings_id;
END$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_refresh_token_get` (IN `p_token` VARCHAR(255))   BEGIN
    SELECT
        rt.id,
        rt.user_id,
        rt.token,
        rt.expires_at,
        rt.revoked_at,
        u.username,
        u.email,
        u.type
    FROM `refresh_token` rt
    INNER JOIN `user` u ON u.id = rt.user_id
    WHERE rt.token = p_token
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_refresh_token_revoke` (IN `p_token` VARCHAR(500))   BEGIN
    UPDATE `refresh_token`
    SET `revoked_at` = CURRENT_TIMESTAMP()
    WHERE `token` = p_token
      AND `revoked_at` IS NULL;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_userInfo_create` (IN `p_user_id` INT(11), IN `p_user_settings_id` INT(11))   BEGIN
    DECLARE v_userInfo_id INT;

    INSERT INTO `userInfo`( `user_id`,  `user_settings_id`) VALUES (p_user_id, p_user_settings_id);

    SET v_userInfo_id = LAST_INSERT_ID();

    SELECT v_userInfo_id AS userInfo_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_confirm_email` (IN `p_user_id` INT)   BEGIN
    UPDATE `user` SET `email_verified` = 1 WHERE `id` = `p_user_id`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_create` (IN `p_username` VARCHAR(25), IN `p_password_hash` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_type` VARCHAR(255))   BEGIN
    DECLARE v_exists_username INT DEFAULT 0;
    DECLARE v_exists_email    INT DEFAULT 0;

    -- HibakezelÃ…â€˜: ha mÃƒÂ©gis lecsÃƒÂºszna egy duplikÃƒÂ¡ciÃƒÂ³ a race condition miatt
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        RESIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'AdatbÃƒÂ¡zis szintÃ…Â± ÃƒÂ¼tkÃƒÂ¶zÃƒÂ©s (duplikÃƒÂ¡lt username vagy email).',
                MYSQL_ERRNO  = 45009;
    END;



    -- KÃƒÂ¶telezÃ…â€˜ mezÃ…â€˜k ellenÃ…â€˜rzÃƒÂ©se
    IF p_username IS NULL OR TRIM(p_username) = '' 
       OR p_password_hash IS NULL OR TRIM(p_password_hash) = ''
       OR p_email IS NULL OR TRIM(p_email) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'HiÃƒÂ¡nyzÃƒÂ³ kÃƒÂ¶telezÃ…â€˜ mezÃ…â€˜ (username, password_hash, email).',
                MYSQL_ERRNO  = 45001;
    END IF;

    -- EgyszerÃ…Â± email formÃƒÂ¡tum ellenÃ…â€˜rzÃƒÂ©s
    IF p_email NOT LIKE '_%@_%.__%' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ãƒâ€°rvÃƒÂ©nytelen email formÃƒÂ¡tum.',
                MYSQL_ERRNO  = 45006;
    END IF;

    -- Username egyedisÃƒÂ©g
    SELECT COUNT(*) INTO v_exists_username
    FROM `user`
    WHERE `username` = p_username;

    IF v_exists_username > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A megadott felhasznÃƒÂ¡lÃƒÂ³nÃƒÂ©v mÃƒÂ¡r foglalt.',
                MYSQL_ERRNO  = 45002;
    END IF;

    -- Email egyedisÃƒÂ©g
    SELECT COUNT(*) INTO v_exists_email
    FROM `user`
    WHERE `email` = p_email;

    IF v_exists_email > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A megadott email cÃƒÂ­m mÃƒÂ¡r foglalt.',
                MYSQL_ERRNO  = 45003;
    END IF;

    INSERT INTO `user` (`username`, `password_hash`, `email`, `type`,`created_at`, `isDeleted`)
    VALUES (p_username, p_password_hash, p_email, p_type,NOW(), 0);

    SELECT `id`, `username`, `password_hash`, `email`, `type` FROM `user` WHERE id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_delete` (IN `p_id` INT)   BEGIN
    DECLARE v_count      INT DEFAULT 0;
    DECLARE v_is_deleted TINYINT(1) DEFAULT 0;

    IF p_id IS NULL OR p_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ã‰rvÃ©nytelen ID.',
                MYSQL_ERRNO  = 45007;
    END IF;

    SELECT COUNT(*), MAX(`isDeleted`) INTO v_count, v_is_deleted
    FROM `user`
    WHERE `id` = p_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasznÃ¡lÃ³ nem talÃ¡lhatÃ³.',
                MYSQL_ERRNO  = 45004;
    END IF;

    IF v_is_deleted = 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasznÃ¡lÃ³ mÃ¡r tÃ¶rÃ¶lve van.',
                MYSQL_ERRNO  = 45005;
    END IF;

    UPDATE `user`
    SET `isDeleted`  = 1,
        `deleted_at` = NOW()
    WHERE `id` = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_get_all` ()   BEGIN
    SELECT id, username, email, created_at, updated_at
    FROM `user`
    WHERE isDeleted = 0
    ORDER BY id;
END$$

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_hard_delete` (IN `p_id` INT)   BEGIN
    DECLARE v_count INT DEFAULT 0;

    IF p_id IS NULL OR p_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ã‰rvÃ©nytelen ID.',
                MYSQL_ERRNO  = 45007;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM `user`
    WHERE `id` = p_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasznÃ¡lÃ³ nem talÃ¡lhatÃ³.',
                MYSQL_ERRNO  = 45004;
    END IF;

    DELETE FROM `user` WHERE `id` = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_list` (IN `p_include_deleted` TINYINT(1))   BEGIN
    IF p_include_deleted = 1 THEN
        SELECT `id`, `username`, `email`, `created_at`, `updated_at`,
               `deleted_at`, `isDeleted`
        FROM `user`
        ORDER BY `id`;
    ELSE
        SELECT `id`, `username`, `email`, `created_at`, `updated_at`,
               `deleted_at`, `isDeleted`
        FROM `user`
        WHERE `isDeleted` = 0
        ORDER BY `id`;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_login` (IN `sp_login_identifiry` VARCHAR(255))   BEGIN
    DECLARE v_count INT DEFAULT 0;

    -- Ãœres/null login azonosÃ­tÃ³ ellenÅ‘rzÃ©se
    IF sp_login_identifiry IS NULL OR TRIM(sp_login_identifiry) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A bejelentkezÃ©si azonosÃ­tÃ³ nem lehet Ã¼res.',
                MYSQL_ERRNO = 45007;
    END IF;

    -- FelhasznÃ¡lÃ³ keresÃ©se email vagy username alapjÃ¡n
    SELECT COUNT(*)
    INTO v_count
    FROM `user`
    WHERE `email` = sp_login_identifiry
       OR `username` = sp_login_identifiry;

    -- Ha nincs talÃ¡lat
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasznÃ¡lÃ³ nem talÃ¡lhatÃ³.',
                MYSQL_ERRNO = 45004;
    END IF;

    -- FelhasznÃ¡lÃ³ visszaadÃ¡sa
    SELECT
        `id`,
        `username`,
        `email`,
        `password_hash`,
        `email_verified`
    FROM `user`
    WHERE `email` = sp_login_identifiry
       OR `username` = sp_login_identifiry;

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_register` (IN `p_username` VARCHAR(25), IN `p_password_hash` VARCHAR(255), IN `p_email` VARCHAR(255))   BEGIN
    DECLARE v_user_id INT;
    DECLARE v_base_settings_id INT;
    DECLARE v_user_settings_id INT;

    call sp_user_create(p_username, p_password_hash, p_email, "user");
    SET v_user_id = LAST_INSERT_ID();

    call sp_base_settings_create(v_user_id);
    SET v_base_settings_id = LAST_INSERT_ID();

    call sp_user_settings_create(v_base_settings_id);
    SET v_user_settings_id = LAST_INSERT_ID();

    call sp_userInfo_create(v_user_id, v_user_settings_id);
    
    SELECT `id`, `username`, `password_hash`, `email`, `type`  FROM `user` WHERE id = v_user_id;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_settings_create` (IN `p_base_settings_id` INT(11))   BEGIN
    DECLARE v_user_settings_id INT;

    INSERT INTO `user_settings`(`settings_id`, `event_reminder`, `new_event_notification`) VALUES (p_base_settings_id, 0 , 0);

    SET v_user_settings_id = LAST_INSERT_ID();

    SELECT v_user_settings_id AS user_settings_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_soft_delete` (IN `p_id` INT)   BEGIN
    UPDATE `user`
    SET isDeleted  = 1,
        deleted_at = NOW()
    WHERE id = p_id
      AND isDeleted = 0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_token_create` (IN `p_user_id` INT, IN `p_token` VARCHAR(255), IN `p_type` VARCHAR(255), IN `p_expires_at` DATETIME)   BEGIN
    DELETE FROM user_token WHERE user_id = p_user_id;
 
    INSERT INTO user_token (user_id, token, token_type,expires_at)
    VALUES (p_user_id, p_token, p_type, p_expires_at);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_token_delete` (IN `p_token` VARCHAR(255))   BEGIN
    DELETE FROM user_token WHERE token = p_token;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_token_get` (IN `p_token` VARCHAR(255))   BEGIN
    SELECT * FROM user_token 
    WHERE token = p_token
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_update` (IN `p_id` INT, IN `p_username` VARCHAR(25), IN `p_password_hash` VARCHAR(255), IN `p_email` VARCHAR(255))   BEGIN
    DECLARE v_count           INT DEFAULT 0;
    DECLARE v_is_deleted      TINYINT(1) DEFAULT 0;
    DECLARE v_exists_username INT DEFAULT 0;
    DECLARE v_exists_email    INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        RESIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'AdatbÃ¡zis szintÅ± Ã¼tkÃ¶zÃ©s (duplikÃ¡lt username vagy email).',
                MYSQL_ERRNO  = 45009;
    END;

    IF p_id IS NULL OR p_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ã‰rvÃ©nytelen ID.',
                MYSQL_ERRNO  = 45007;
    END IF;

    IF p_username IS NULL AND p_password_hash IS NULL AND p_email IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nincs mÃ³dosÃ­tandÃ³ mezÅ‘ megadva.',
                MYSQL_ERRNO  = 45008;
    END IF;

    SELECT COUNT(*), MAX(`isDeleted`) INTO v_count, v_is_deleted
    FROM `user`
    WHERE `id` = p_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasznÃ¡lÃ³ nem talÃ¡lhatÃ³.',
                MYSQL_ERRNO  = 45004;
    END IF;

    IF v_is_deleted = 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasznÃ¡lÃ³ tÃ¶rÃ¶lve van, nem mÃ³dosÃ­thatÃ³.',
                MYSQL_ERRNO  = 45005;
    END IF;

    IF p_email IS NOT NULL AND p_email NOT LIKE '_%@_%.__%' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ã‰rvÃ©nytelen email formÃ¡tum.',
                MYSQL_ERRNO  = 45006;
    END IF;

    IF p_username IS NOT NULL THEN
        SELECT COUNT(*) INTO v_exists_username
        FROM `user`
        WHERE `username` = p_username AND `id` <> p_id;

        IF v_exists_username > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A megadott felhasznÃ¡lÃ³nÃ©v mÃ¡r foglalt.',
                    MYSQL_ERRNO  = 45002;
        END IF;
    END IF;

    IF p_email IS NOT NULL THEN
        SELECT COUNT(*) INTO v_exists_email
        FROM `user`
        WHERE `email` = p_email AND `id` <> p_id;

        IF v_exists_email > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A megadott email cÃ­m mÃ¡r foglalt.',
                    MYSQL_ERRNO  = 45003;
        END IF;
    END IF;

    UPDATE `user`
    SET `username`      = COALESCE(p_username, `username`),
        `password_hash` = COALESCE(p_password_hash, `password_hash`),
        `email`         = COALESCE(p_email, `email`),
        `updated_at`    = NOW()
    WHERE `id` = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_update_password` (IN `p_user_id` INT, IN `p_password_hash` VARCHAR(255))   BEGIN
    UPDATE user SET password_hash = p_password_hash WHERE id = p_user_id;
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
