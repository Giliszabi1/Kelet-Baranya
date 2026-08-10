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
        `password_hash`
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
