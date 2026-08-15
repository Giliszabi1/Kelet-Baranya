
-- =========================================================
-- User tábla
-- =========================================================
USE `kelet_baranya_db`;

DELIMITER $$

-- ---------------------------------------------------------
-- CREATE
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_user_create$$
CREATE PROCEDURE sp_user_create(
    IN  p_username      VARCHAR(25),
    IN  p_password_hash VARCHAR(255),  -- a jelszót MINDIG az alkalmazás
                                        -- oldalon hasheld, ide már a hash jön
    IN  p_email         VARCHAR(255),
    OUT p_new_id        INT
)
BEGIN
    INSERT INTO `user` (username, password_hash, email)
    VALUES (p_username, p_password_hash, p_email);

    SET p_new_id = LAST_INSERT_ID();
END$$

-- ---------------------------------------------------------
-- READ
-- ---------------------------------------------------------
/*
DROP PROCEDURE IF EXISTS sp_user_get_by_id$$
CREATE PROCEDURE sp_user_get_by_id(
    IN p_id INT
)
BEGIN
    SELECT id, username, email, created_at, updated_at
    FROM `user`
    WHERE id = p_id
      AND isDeleted = 0;
END$$

-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_user_get_all$$
CREATE PROCEDURE sp_user_get_all()
BEGIN
    SELECT id, username, email, created_at, updated_at
    FROM `user`
    WHERE isDeleted = 0
    ORDER BY id;
END$$
*/
-- ---------------------------------------------------------
-- UPDATE
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_user_update$$
CREATE PROCEDURE sp_user_update(
    IN p_id       INT,
    IN p_username VARCHAR(25),
    IN p_email    VARCHAR(255)
)
BEGIN
    UPDATE `user`
    SET username   = p_username,
        email      = p_email,
        updated_at = NOW()
    WHERE id = p_id
      AND isDeleted = 0;
END$$

-- ---------------------------------------------------------
-- SOFT DELETE
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_user_soft_delete$$
CREATE PROCEDURE sp_user_soft_delete(
    IN p_id INT
)
BEGIN
    UPDATE `user`
    SET isDeleted  = 1,
        deleted_at = NOW()
    WHERE id = p_id
      AND isDeleted = 0;
END$$

DELIMITER ;

-- =========================================================
-- Gyors teszt (opcionális, futtasd le, hogy lásd működik-e)
-- =========================================================
-- CALL sp_user_create('teszt_elek', 'ide_jonne_egy_hash', 'teszt@pelda.hu', @uj_id);
-- SELECT @uj_id;
-- CALL sp_user_get_by_id(@uj_id);
-- CALL sp_user_update(@uj_id, 'teszt_elek2', 'teszt2@pelda.hu');
-- CALL sp_user_get_all();
-- CALL sp_user_soft_delete(@uj_id);
-- CALL sp_user_get_by_id(@uj_id);  -- ez már nem ad vissza semmit, mert isDeleted=1


-- =========================================================
-- Event tábla
-- =========================================================

DELIMITER $$

-- ---------------------------------------------------------
-- CREATE
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_event_create$$
CREATE PROCEDURE sp_event_create(
    IN  p_title         VARCHAR(75),
    IN  p_location_id   INT,
    IN  p_start_time    DATETIME,
    IN  p_end_time      DATETIME,
    IN  p_description   TEXT,
    IN  p_group_id      INT,
    IN  p_max_participants int,
    IN  p_rating decimal(2,1),
    IN  p_repeat_id int,
    IN  p_approved_status ENUM("pending", "approved", "denied"),
    IN  p_created_by_user_id int,
    OUT p_new_id        INT
)
BEGIN
INSERT INTO `event`(`title`, `location_id`, `start_time`, `end_time`, `description`, `group_id`, `max_participants`, `rating`, `repeat_id`, `approved_status`, `created_by_user_id`, `created_at`, `isDeleted`)
 VALUES ('p_title','p_location_id','p_start_time','p_end_time','p_description','p_group_id','p_max_participants','p_rating','p_repeat_id','p_approved_status','p_created_by_user_id', NOW(),'0');

    SET p_new_id = LAST_INSERT_ID();
END$$

-- ---------------------------------------------------------
-- READ
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_event_get_by_id$$
CREATE PROCEDURE sp_event_get_by_id(
    IN p_id INT
)
BEGIN
    SELECT `id`, `title`, `location_id`, `start_time`, `end_time`, `description`, `group_id`, `max_participants`, `rating`, `repeat_id`, `approved_status`, `created_by_user_id`, `created_at`, `updated_at`
    FROM `user`
    WHERE id = p_id
      AND isDeleted = 0;
END$$

-- ---------------------------------------------------------
-- READ - összes aktív felhasználó listázása
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_user_get_all$$
CREATE PROCEDURE sp_user_get_all()
BEGIN
    SELECT id, username, email, created_at, updated_at
    FROM `user`
    WHERE isDeleted = 0
    ORDER BY id;
END$$

-- ---------------------------------------------------------
-- UPDATE
-- Csak azt frissítjük, ami módosítható; updated_at-et
-- mindig NOW()-ra állítjuk, hogy lássuk mikor volt utoljára
-- szerkesztve.
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_user_update$$
CREATE PROCEDURE sp_user_update(
    IN p_id       INT,
    IN p_username VARCHAR(25),
    IN p_email    VARCHAR(255)
)
BEGIN
    UPDATE `user`
    SET username   = p_username,
        email      = p_email,
        updated_at = NOW()
    WHERE id = p_id
      AND isDeleted = 0;
END$$

-- ---------------------------------------------------------
-- SOFT DELETE
-- Nem töröljük fizikailag a sort, csak megjelöljük töröltnek,
-- és eltároljuk mikor történt a törlés.
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_user_soft_delete$$
CREATE PROCEDURE sp_user_soft_delete(
    IN p_id INT
)
BEGIN
    UPDATE `user`
    SET isDeleted  = 1,
        deleted_at = NOW()
    WHERE id = p_id
      AND isDeleted = 0;
END$$

DELIMITER ;
