#
#       Kelet-Baranya database shema
#

DROP DATABASE IF EXISTS kelet-baranya_db;

CREATE DATABASE kelet - baranya_db;

USE kelet - baranya_db;

CREATE TABLE `user` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `username` varchar(25) UNIQUE NOT NULL,
    `password_hash` varchar(255) NOT NULL,
    `email` varchar(255) UNIQUE NOT NULL,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `deleted_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `userInfo` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT UNIQUE NOT NULL,
    `image_id` INT,
    `user_settings_id` INT,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `adminInfo` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT UNIQUE NOT NULL,
    `admin_settings_id` INT,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `organizerInfo` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT UNIQUE NOT NULL,
    `image_id` INT,
    /*null means no image*/ `bio` text,
    `rating` decimal(2, 1) DEFAULT 0,
    `organizer_settings_id` int,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `organizer_review` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `reviewer_id` INT,
    `reviewed_id` INT,
    `rating` tinyint DEFAULT 0,
    `comment` text,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `base_settings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `language` varchar(10) DEFAULT 'hu',
    `unit_system` ENUM('metric', 'imperial') DEFAULT 'metric',
    `push_notification` tinyint DEFAULT 1,
    `email_notification` tinyint DEFAULT 1,
    `dark_mode` tinyint DEFAULT 0,
    `updated_at` datetime
);

CREATE TABLE `user_settings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `settings_id` INT NOT NULL,
    `event_reminder` tinyint DEFAULT 1,
    `new_event_notification` tinyint DEFAULT 1,
    `updated_at` datetime
);

CREATE TABLE `admin_settings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `settings_id` INT NOT NULL,
    `event_reminder` tinyint DEFAULT 1,
    `new_event_notification` tinyint DEFAULT 1,
    `updated_at` datetime
);

CREATE TABLE `organizer_settings` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `settings_id` INT NOT NULL,
    `event_approved_notification` tinyint DEFAULT 1,
    `updated_at` datetime
);

CREATE TABLE `user_favourite_location` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `location_id` INT NOT NULL,
    `created_at` datetime DEFAULT(now())
);

CREATE TABLE `user_favourite_event` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `event_id` INT NOT NULL,
    `created_at` datetime DEFAULT(now())
);

CREATE TABLE `friend_request` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `sender_id` INT NOT NULL,
    `receiver_id` INT NOT NULL,
    `status` ENUM(
        'pending',
        'accepted',
        'declined'
    ) DEFAULT 'pending',
    `created_at` datetime DEFAULT(now()),
    `responded_at` datetime
);

CREATE TABLE `location` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` varchar(50) UNIQUE NOT NULL,
    `address` varchar(255),
    `description` text,
    `rating` decimal(2, 1) DEFAULT 0,
    `group_id` INT,
    `created_by_user_id` INT NOT NULL,
    `approved_status` ENUM(
        'pending',
        'approved',
        'denied'
    ) DEFAULT 'pending',
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `deleted_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `location_category` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `location_id` INT NOT NULL,
    `category_id` INT NOT NULL
);

CREATE TABLE `location_review` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `location_id` INT NOT NULL,
    `rating` tinyint NOT NULL,
    `comment` text,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `location_image` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `location_id` INT NOT NULL,
    `image_id` INT NOT NULL,
    `sort_order` INT DEFAULT 0
);

CREATE TABLE `event` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` varchar(75) NOT NULL,
    `location_id` INT NOT NULL,
    `start_time` datetime NOT NULL,
    `end_time` datetime,
    `description` text,
    `group_id` INT,
    `max_participants` INT,
    `rating` decimal(2, 1) DEFAULT 0,
    `repeat_id` INT,
    `approved_status` ENUM(
        'pending',
        'approved',
        'denied'
    ) DEFAULT 'pending',
    `created_by_user_id` INT NOT NULL,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `deleted_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `event_category` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `event_id` INT NOT NULL,
    `category_id` INT NOT NULL
);

CREATE TABLE `event_review` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `event_id` INT NOT NULL,
    `rating` tinyint NOT NULL,
    `comment` text,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `event_participant` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `event_id` INT NOT NULL,
    `status` ENUM(
        'interested',
        'going',
        'not_going'
    ) DEFAULT 'interested',
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime
);

CREATE TABLE `event_image` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `event_id` INT NOT NULL,
    `image_id` INT NOT NULL,
    `sort_order` INT DEFAULT 0
);

CREATE TABLE `event_repeat` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `created_by_user_id` INT NOT NULL,
    `event_id` INT NOT NULL,
    `interval_days` INT NOT NULL,
    `first_event` date,
    `nd_date` date,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `deleted_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `group` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` varchar(50) NOT NULL,
    `image_id` INT,
    `description` text,
    `created_by` INT NOT NULL,
    `created_at` datetime DEFAULT(now()),
    `updated_at` datetime,
    `deleted_at` datetime,
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `group_member` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `group_id` INT NOT NULL,
    `created_at` datetime DEFAULT(now()),
    `joined_at` datetime DEFAULT(now())
);

CREATE TABLE `category` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` varchar(50),
    `image_id` INT
);

CREATE TABLE `image` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` varchar(25) NOT NULL,
    `path` text UNIQUE NOT NULL,
    `type` ENUM(
        'profile',
        'location',
        'event',
        'group',
        'category'
    ) NOT NULL,
    `created_by` int,
    `created_at` datetime DEFAULT(now()),
    `isDeleted` bool DEFAULT 0
);

CREATE TABLE `current_weather` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `city_name` varchar(25),
    `weather_main` varchar(15),
    `main_temp` decimal(4, 2),
    `main_temp_feels_like` decimal(4, 2),
    `visibility` INT,
    `wind_speed` decimal(4, 2)
);

CREATE TABLE `forecast_weather` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `city_name` varchar(25),
    `weather_main` varchar(15),
    `main_temp` decimal(4, 2),
    `main_temp_feels_like` decimal(4, 2),
    `visibility` INT,
    `wind_speed` decimal(4, 2)
);

CREATE UNIQUE INDEX `organizer_review_index_0` ON `organizer_review` (`reviewer_id`, `reviewed_id`);

CREATE UNIQUE INDEX `user_favourite_location_index_1` ON `user_favourite_location` (`user_id`, `location_id`);

CREATE UNIQUE INDEX `user_favourite_event_index_2` ON `user_favourite_event` (`user_id`, `event_id`);

CREATE UNIQUE INDEX `friend_request_index_3` ON `friend_request` (`sender_id`, `receiver_id`);

CREATE UNIQUE INDEX `location_category_index_4` ON `location_category` (`location_id`, `category_id`);

CREATE UNIQUE INDEX `location_review_index_5` ON `location_review` (`user_id`, `location_id`);

CREATE UNIQUE INDEX `event_category_index_6` ON `event_category` (`event_id`, `category_id`);

CREATE UNIQUE INDEX `event_review_index_7` ON `event_review` (`user_id`, `event_id`);

CREATE UNIQUE INDEX `event_participant_index_8` ON `event_participant` (`user_id`, `event_id`);

CREATE UNIQUE INDEX `event_repeat_index_9` ON `event_repeat` (
    `created_by_user_id`,
    `event_id`
);

CREATE UNIQUE INDEX `group_member_index_10` ON `group_member` (`user_id`, `group_id`);

ALTER TABLE `userInfo`
ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `userInfo`
ADD FOREIGN KEY (`image_id`) REFERENCES `image` (`id`);

ALTER TABLE `userInfo`
ADD FOREIGN KEY (`user_settings_id`) REFERENCES `user_settings` (`id`);

ALTER TABLE `adminInfo`
ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `adminInfo`
ADD FOREIGN KEY (`admin_settings_id`) REFERENCES `admin_settings` (`id`);

ALTER TABLE `organizerInfo`
ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `organizerInfo`
ADD FOREIGN KEY (`image_id`) REFERENCES `image` (`id`);

ALTER TABLE `organizerInfo`
ADD FOREIGN KEY (`organizer_settings_id`) REFERENCES `organizer_settings` (`id`);

ALTER TABLE `organizer_review`
ADD FOREIGN KEY (`reviewer_id`) REFERENCES `user` (`id`);

ALTER TABLE `organizer_review`
ADD FOREIGN KEY (`reviewed_id`) REFERENCES `user` (`id`);

ALTER TABLE `user_settings`
ADD FOREIGN KEY (`settings_id`) REFERENCES `base_settings` (`id`);

ALTER TABLE `admin_settings`
ADD FOREIGN KEY (`settings_id`) REFERENCES `base_settings` (`id`);

ALTER TABLE `organizer_settings`
ADD FOREIGN KEY (`settings_id`) REFERENCES `base_settings` (`id`);

ALTER TABLE `user_favourite_location`
ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `user_favourite_location`
ADD FOREIGN KEY (`location_id`) REFERENCES `location` (`id`);

ALTER TABLE `user_favourite_event`
ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `user_favourite_event`
ADD FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

ALTER TABLE `friend_request`
ADD FOREIGN KEY (`sender_id`) REFERENCES `user` (`id`);

ALTER TABLE `friend_request`
ADD FOREIGN KEY (`receiver_id`) REFERENCES `user` (`id`);

ALTER TABLE `location`
ADD FOREIGN KEY (`group_id`) REFERENCES `group` (`id`);

ALTER TABLE `location`
ADD FOREIGN KEY (`created_by_user_id`) REFERENCES `user` (`id`);

ALTER TABLE `location_category`
ADD FOREIGN KEY (`location_id`) REFERENCES `location` (`id`);

ALTER TABLE `location_category`
ADD FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

ALTER TABLE `location_review`
ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `location_review`
ADD FOREIGN KEY (`location_id`) REFERENCES `location` (`id`);

ALTER TABLE `location_image`
ADD FOREIGN KEY (`location_id`) REFERENCES `location` (`id`);

ALTER TABLE `location_image`
ADD FOREIGN KEY (`image_id`) REFERENCES `image` (`id`);

ALTER TABLE `event`
ADD FOREIGN KEY (`location_id`) REFERENCES `location` (`id`);

ALTER TABLE `event`
ADD FOREIGN KEY (`group_id`) REFERENCES `group` (`id`);

ALTER TABLE `event`
ADD FOREIGN KEY (`repeat_id`) REFERENCES `event_repeat` (`id`);

ALTER TABLE `event`
ADD FOREIGN KEY (`created_by_user_id`) REFERENCES `user` (`id`);

ALTER TABLE `event_category`
ADD FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

ALTER TABLE `event_category`
ADD FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

ALTER TABLE `event_review`
ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `event_review`
ADD FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

ALTER TABLE `event_participant`
ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `event_participant`
ADD FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

ALTER TABLE `event_image`
ADD FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

ALTER TABLE `event_image`
ADD FOREIGN KEY (`image_id`) REFERENCES `image` (`id`);

ALTER TABLE `event_repeat`
ADD FOREIGN KEY (`created_by_user_id`) REFERENCES `user` (`id`);

ALTER TABLE `event_repeat`
ADD FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

ALTER TABLE `group`
ADD FOREIGN KEY (`image_id`) REFERENCES `image` (`id`);

ALTER TABLE `group`
ADD FOREIGN KEY (`created_by`) REFERENCES `user` (`id`);

ALTER TABLE `group_member`
ADD FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `group_member`
ADD FOREIGN KEY (`group_id`) REFERENCES `group` (`id`);

ALTER TABLE `category`
ADD FOREIGN KEY (`image_id`) REFERENCES `image` (`id`);

ALTER TABLE `image`
ADD FOREIGN KEY (`created_by`) REFERENCES `user` (`id`);