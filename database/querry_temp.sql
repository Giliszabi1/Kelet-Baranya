-- =====================================================================
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

-- =====================================================================
-- CREATE
-- =====================================================================
DROP PROCEDURE IF EXISTS `sp_user_create` $$
CREATE PROCEDURE `sp_user_create` (
    IN  p_username      VARCHAR(25),
    IN  p_password_hash VARCHAR(255),
    IN  p_email         VARCHAR(255),
    OUT p_new_id        INT
)
BEGIN
    DECLARE v_exists_username INT DEFAULT 0;
    DECLARE v_exists_email    INT DEFAULT 0;

    -- Hibakezelő: ha mégis lecsúszna egy duplikáció a race condition miatt
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        RESIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Adatbázis szintű ütközés (duplikált username vagy email).',
                MYSQL_ERRNO  = 45009;
    END;

    -- Kötelező mezők ellenőrzése
    IF p_username IS NULL OR TRIM(p_username) = '' 
       OR p_password_hash IS NULL OR TRIM(p_password_hash) = ''
       OR p_email IS NULL OR TRIM(p_email) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hiányzó kötelező mező (username, password_hash, email).',
                MYSQL_ERRNO  = 45001;
    END IF;

    -- Egyszerű email formátum ellenőrzés
    IF p_email NOT LIKE '_%@_%.__%' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Érvénytelen email formátum.',
                MYSQL_ERRNO  = 45006;
    END IF;

    -- Username egyediség
    SELECT COUNT(*) INTO v_exists_username
    FROM `user`
    WHERE `username` = p_username;

    IF v_exists_username > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A megadott felhasználónév már foglalt.',
                MYSQL_ERRNO  = 45002;
    END IF;

    -- Email egyediség
    SELECT COUNT(*) INTO v_exists_email
    FROM `user`
    WHERE `email` = p_email;

    IF v_exists_email > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A megadott email cím már foglalt.',
                MYSQL_ERRNO  = 45003;
    END IF;

    INSERT INTO `user` (`username`, `password_hash`, `email`, `created_at`, `isDeleted`)
    VALUES (p_username, p_password_hash, p_email, NOW(), 0);

    SET p_new_id = LAST_INSERT_ID();
END $$


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





-- =====================================================================
-- USER INFO TÁBLA + CRUD (Stored Procedures) HIBAKÓDOKKAL
-- MySQL / InnoDB
-- =====================================================================

-- ---------------------------------------------------------------------
-- HIBAKÓD-KONVENCIÓ (saját alkalmazási hibák, MYSQL_ERRNO mezővel)
-- ---------------------------------------------------------------------
-- 45001  - Hiányzó kötelező mező
-- 45002  - User ID már foglalt
-- 45003  - User settings már foglalt
-- 45004  - Felhasználó nem található (id alapján)
-- 45005  - Felhasználó már törölve van (soft delete)
-- 45006  - Image ID nem található
-- 45007  - Érvénytelen ID (pl. <= 0 vagy NULL)
-- 45008  - Nincs módosítandó mező megadva UPDATE-nél
-- Ezek mellett a natív MySQL hibák (pl. 1062 duplicate entry) is
-- előfordulhatnak, ha valaki nem a proceduren keresztül ír a táblába.
-- ---------------------------------------------------------------------
/*
DELIMITER $$

-- =====================================================================
-- CREATE
-- =====================================================================
DROP PROCEDURE IF EXISTS `sp_userInfo_create` $$
CREATE PROCEDURE `sp_userInfo_create` (
    IN  p_username      VARCHAR(25),
    IN  p_password_hash VARCHAR(255),
    IN  p_email         VARCHAR(255),
    OUT p_new_id        INT
)
BEGIN
    DECLARE v_exists_username INT DEFAULT 0;
    DECLARE v_exists_email    INT DEFAULT 0;

    -- Hibakezelő: ha mégis lecsúszna egy duplikáció a race condition miatt
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        RESIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Adatbázis szintű ütközés (duplikált username vagy email).',
                MYSQL_ERRNO  = 45009;
    END;

    -- Kötelező mezők ellenőrzése
    IF p_username IS NULL OR TRIM(p_username) = '' 
       OR p_password_hash IS NULL OR TRIM(p_password_hash) = ''
       OR p_email IS NULL OR TRIM(p_email) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hiányzó kötelező mező (username, password_hash, email).',
                MYSQL_ERRNO  = 45001;
    END IF;

    -- Egyszerű email formátum ellenőrzés
    IF p_email NOT LIKE '_%@_%.__%' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Érvénytelen email formátum.',
                MYSQL_ERRNO  = 45006;
    END IF;

    -- Username egyediség
    SELECT COUNT(*) INTO v_exists_username
    FROM `user`
    WHERE `username` = p_username;

    IF v_exists_username > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A megadott felhasználónév már foglalt.',
                MYSQL_ERRNO  = 45002;
    END IF;

    -- Email egyediség
    SELECT COUNT(*) INTO v_exists_email
    FROM `user`
    WHERE `email` = p_email;

    IF v_exists_email > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A megadott email cím már foglalt.',
                MYSQL_ERRNO  = 45003;
    END IF;

    INSERT INTO `user` (`username`, `password_hash`, `email`, `created_at`, `isDeleted`)
    VALUES (p_username, p_password_hash, p_email, NOW(), 0);

    SET p_new_id = LAST_INSERT_ID();
END $$


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
*/