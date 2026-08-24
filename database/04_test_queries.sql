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