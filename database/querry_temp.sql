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

DELIMITER $$

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

DROP PROCEDURE IF EXISTS `sp_delete_all_data`$$

CREATE PROCEDURE `sp_delete_all_data`()
BEGIN
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

DROP PROCEDURE IF EXISTS sp_user_get_by_id;
CREATE PROCEDURE sp_user_get_by_id(IN p_user_id BIGINT)
BEGIN
    DECLARE v_email_verified TINYINT DEFAULT NULL;

    SELECT email_verified
    INTO v_email_verified
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

DROP PROCEDURE IF EXISTS `sp_user_confirm_email`;
CREATE PROCEDURE `sp_user_confirm_email`(IN `p_user_id` INT)
BEGIN
    UPDATE `user` SET `email_verified` = 1 WHERE `id` = `p_user_id`;
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

DROP PROCEDURE IF EXISTS `sp_userInfo_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_userInfo_create` (IN `p_user_id` INT(11), IN `p_user_settings_id` INT(11))   BEGIN
    DECLARE v_userInfo_id INT;

    INSERT INTO `userInfo`( `user_id`,  `user_settings_id`) VALUES (p_user_id, p_user_settings_id);

    SET v_userInfo_id = LAST_INSERT_ID();

    SELECT v_userInfo_id AS userInfo_id;
END$$

DROP PROCEDURE IF EXISTS `sp_user_register`$$
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

DROP PROCEDURE IF EXISTS `sp_user_settings_create`$$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_user_settings_create` (IN `p_base_settings_id` INT(11))   BEGIN
    DECLARE v_user_settings_id INT;

    INSERT INTO `user_settings`(`settings_id`, `event_reminder`, `new_event_notification`) VALUES (p_base_settings_id, 0 , 0);

    SET v_user_settings_id = LAST_INSERT_ID();

    SELECT v_user_settings_id AS user_settings_id;
END$$

DROP PROCEDURE IF EXISTS `sp_refresh_token_create` $$
CREATE PROCEDURE `sp_refresh_token_create` (
    IN p_user_id INT(11),
    IN p_token VARCHAR(255),
    IN p_user_agent text,
    IN p_accept_language VARCHAR(255),
    IN p_sec_ch_ua text,
    IN p_sec_ch_ua_mobile VARCHAR(20),
    IN p_sec_ch_ua_platform VARCHAR(50),
    IN p_expires_at DATETIME
)
BEGIN
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
END $$

DROP PROCEDURE IF EXISTS `sp_refresh_token_get` $$
CREATE PROCEDURE `sp_refresh_token_get` (
    IN p_token VARCHAR(255)
)
BEGIN
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
END $$

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
 
-- Token lekérdezése (érvényesség ellenőrzéséhez)
DROP PROCEDURE IF EXISTS `sp_user_token_get`$$
CREATE PROCEDURE `sp_user_token_get`(
    IN p_token VARCHAR(255)
)
BEGIN
    SELECT * FROM user_token 
    WHERE token = p_token
    LIMIT 1;
END$$
 
-- Token törlése (sikeres jelszó-csere után, vagy lejárt token esetén)
DROP PROCEDURE IF EXISTS `sp_user_token_delete`$$
CREATE PROCEDURE `sp_user_token_delete`(
    IN p_token VARCHAR(255)
)
BEGIN
    DELETE FROM user_token WHERE token = p_token;
END$$
 
-- Jelszó frissítése
-- FONTOS: ellenőrizd, hogy nálad is `users` a tábla neve és
-- `password_hash` az oszlop neve — ha más, itt írd át!
DROP PROCEDURE IF EXISTS `sp_user_update_password`$$
CREATE PROCEDURE `sp_user_update_password`(
    IN p_user_id INT,
    IN p_password_hash VARCHAR(255)
)
BEGIN
    UPDATE user SET password_hash = p_password_hash WHERE id = p_user_id;
END$$

-- =====================================================================
-- CREATE
-- =====================================================================
DROP PROCEDURE IF EXISTS `sp_user_create`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_user_create` (IN `p_username` VARCHAR(25), IN `p_password_hash` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_type` VARCHAR(255))   BEGIN
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

    INSERT INTO `user` (`username`, `password_hash`, `email`, `type`,`created_at`, `isDeleted`)
    VALUES (p_username, p_password_hash, p_email, p_type,NOW(), 0);

    SELECT `id`, `username`, `password_hash`, `email`, `type` FROM `user` WHERE id = LAST_INSERT_ID();
END$$

-- =====================================================================
-- READ - egy felhasználó lekérdezése ID alapján
-- =====================================================================
/*
DROP PROCEDURE IF EXISTS `sp_user_get_by_id` $$
CREATE PROCEDURE `sp_user_get_by_id` (
    IN p_id INT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    IF p_id IS NULL OR p_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Érvénytelen ID.',
                MYSQL_ERRNO  = 45007;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM `user`
    WHERE `id` = p_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasználó nem található.',
                MYSQL_ERRNO  = 45004;
    END IF;

    SELECT `id`, `username`, `email`, `created_at`, `updated_at`,
           `deleted_at`, `isDeleted`
    FROM `user`
    WHERE `id` = p_id;
END $$
*/
-- sp

DROP PROCEDURE IF EXISTS `sp_user_login` $$
CREATE PROCEDURE `sp_user_login` (
    IN sp_login_identifiry VARCHAR(255)
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

    -- Felhasználó visszaadása
    SELECT
        `id`,
        `username`,
        `email`,
        `password_hash`,
        `email_verified`,
        `two_factor_enabled` 
    FROM `user`
    WHERE `email` = sp_login_identifiry
       OR `username` = sp_login_identifiry;

END $$

-- =====================================================================
-- READ - összes aktív (nem törölt) felhasználó listázása
-- =====================================================================
DROP PROCEDURE IF EXISTS `sp_user_list` $$
CREATE PROCEDURE `sp_user_list` (
    IN p_include_deleted TINYINT(1)
)
BEGIN
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
END $$


-- =====================================================================
-- UPDATE - felhasználó adatainak módosítása (dinamikus, csak a
-- megadott mezőket írja felül; NULL paraméter = "nem változik")
-- =====================================================================
DROP PROCEDURE IF EXISTS `sp_user_update` $$
CREATE PROCEDURE `sp_user_update` (
    IN p_id             INT,
    IN p_username       VARCHAR(25),
    IN p_password_hash  VARCHAR(255),
    IN p_email          VARCHAR(255)
)
BEGIN
    DECLARE v_count           INT DEFAULT 0;
    DECLARE v_is_deleted      TINYINT(1) DEFAULT 0;
    DECLARE v_exists_username INT DEFAULT 0;
    DECLARE v_exists_email    INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        RESIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Adatbázis szintű ütközés (duplikált username vagy email).',
                MYSQL_ERRNO  = 45009;
    END;

    IF p_id IS NULL OR p_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Érvénytelen ID.',
                MYSQL_ERRNO  = 45007;
    END IF;

    IF p_username IS NULL AND p_password_hash IS NULL AND p_email IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nincs módosítandó mező megadva.',
                MYSQL_ERRNO  = 45008;
    END IF;

    SELECT COUNT(*), MAX(`isDeleted`) INTO v_count, v_is_deleted
    FROM `user`
    WHERE `id` = p_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasználó nem található.',
                MYSQL_ERRNO  = 45004;
    END IF;

    IF v_is_deleted = 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasználó törölve van, nem módosítható.',
                MYSQL_ERRNO  = 45005;
    END IF;

    IF p_email IS NOT NULL AND p_email NOT LIKE '_%@_%.__%' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Érvénytelen email formátum.',
                MYSQL_ERRNO  = 45006;
    END IF;

    IF p_username IS NOT NULL THEN
        SELECT COUNT(*) INTO v_exists_username
        FROM `user`
        WHERE `username` = p_username AND `id` <> p_id;

        IF v_exists_username > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A megadott felhasználónév már foglalt.',
                    MYSQL_ERRNO  = 45002;
        END IF;
    END IF;

    IF p_email IS NOT NULL THEN
        SELECT COUNT(*) INTO v_exists_email
        FROM `user`
        WHERE `email` = p_email AND `id` <> p_id;

        IF v_exists_email > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A megadott email cím már foglalt.',
                    MYSQL_ERRNO  = 45003;
        END IF;
    END IF;

    UPDATE `user`
    SET `username`      = COALESCE(p_username, `username`),
        `password_hash` = COALESCE(p_password_hash, `password_hash`),
        `email`         = COALESCE(p_email, `email`),
        `updated_at`    = NOW()
    WHERE `id` = p_id;
END $$


-- =====================================================================
-- DELETE - soft delete (isDeleted + deleted_at)
-- =====================================================================
DROP PROCEDURE IF EXISTS `sp_user_delete` $$
CREATE PROCEDURE `sp_user_delete` (
    IN p_id INT
)
BEGIN
    DECLARE v_count      INT DEFAULT 0;
    DECLARE v_is_deleted TINYINT(1) DEFAULT 0;

    IF p_id IS NULL OR p_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Érvénytelen ID.',
                MYSQL_ERRNO  = 45007;
    END IF;

    SELECT COUNT(*), MAX(`isDeleted`) INTO v_count, v_is_deleted
    FROM `user`
    WHERE `id` = p_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasználó nem található.',
                MYSQL_ERRNO  = 45004;
    END IF;

    IF v_is_deleted = 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasználó már törölve van.',
                MYSQL_ERRNO  = 45005;
    END IF;

    UPDATE `user`
    SET `isDeleted`  = 1,
        `deleted_at` = NOW()
    WHERE `id` = p_id;
END $$


-- =====================================================================
-- (Opcionális) HARD DELETE - végleges törlés, csak ha tényleg kell
-- =====================================================================
DROP PROCEDURE IF EXISTS `sp_user_hard_delete` $$
CREATE PROCEDURE `sp_user_hard_delete` (
    IN p_id INT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    IF p_id IS NULL OR p_id <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Érvénytelen ID.',
                MYSQL_ERRNO  = 45007;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM `user`
    WHERE `id` = p_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A felhasználó nem található.',
                MYSQL_ERRNO  = 45004;
    END IF;

    DELETE FROM `user` WHERE `id` = p_id;
END $$

DELIMITER ;

-- =====================================================================
-- PÉLDA HASZNÁLAT
-- =====================================================================
-- CALL sp_user_create('teszt_elek', 'hash_ide', 'teszt@example.com', @new_id);
-- SELECT @new_id;
--
-- CALL sp_user_get_by_id(1);
-- CALL sp_user_list(0);              -- csak aktívak
-- CALL sp_user_list(1);              -- töröltekkel együtt
--
-- CALL sp_user_update(1, NULL, NULL, 'uj_email@example.com');
-- CALL sp_user_delete(1);
-- CALL sp_user_hard_delete(1);
