-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: localhost
-- Létrehozás ideje: 2026. Aug 05. 11:00
-- Kiszolgáló verziója: 10.4.32-MariaDB
-- PHP verzió: 8.2.12

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
CREATE DATABASE IF NOT EXISTS `kelet_baranya_db` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `kelet_baranya_db`;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `adminInfo`
--

DROP TABLE IF EXISTS `adminInfo`;
CREATE TABLE `adminInfo` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `admin_settings_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `admin_settings`
--

DROP TABLE IF EXISTS `admin_settings`;
CREATE TABLE `admin_settings` (
  `id` int(11) NOT NULL,
  `settings_id` int(11) NOT NULL,
  `event_reminder` tinyint(4) DEFAULT 1,
  `new_event_notification` tinyint(4) DEFAULT 1,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `base_settings`
--

DROP TABLE IF EXISTS `base_settings`;
CREATE TABLE `base_settings` (
  `id` int(11) NOT NULL,
  `language` varchar(10) DEFAULT 'hu',
  `unit_system` enum('metric','imperial') DEFAULT 'metric',
  `push_notification` tinyint(4) DEFAULT 1,
  `email_notification` tinyint(4) DEFAULT 1,
  `dark_mode` tinyint(4) DEFAULT 0,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `category`
--

DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `image_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `current_weather`
--

DROP TABLE IF EXISTS `current_weather`;
CREATE TABLE `current_weather` (
  `id` int(11) NOT NULL,
  `city_name` varchar(25) DEFAULT NULL,
  `weather_main` varchar(15) DEFAULT NULL,
  `main_temp` decimal(4,2) DEFAULT NULL,
  `main_temp_feels_like` decimal(4,2) DEFAULT NULL,
  `visibility` int(11) DEFAULT NULL,
  `wind_speed` decimal(4,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `event`
--

DROP TABLE IF EXISTS `event`;
CREATE TABLE `event` (
  `id` int(11) NOT NULL,
  `title` varchar(75) NOT NULL,
  `location_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `description` text DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `max_participants` int(11) DEFAULT NULL,
  `rating` decimal(2,1) DEFAULT 0.0,
  `repeat_id` int(11) DEFAULT NULL,
  `approved_status` enum('pending','approved','denied') DEFAULT 'pending',
  `created_by_user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `event_category`
--

DROP TABLE IF EXISTS `event_category`;
CREATE TABLE `event_category` (
  `id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `event_image`
--

DROP TABLE IF EXISTS `event_image`;
CREATE TABLE `event_image` (
  `id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `image_id` int(11) NOT NULL,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `event_participant`
--

DROP TABLE IF EXISTS `event_participant`;
CREATE TABLE `event_participant` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `status` enum('interested','going','not_going') DEFAULT 'interested',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `event_repeat`
--

DROP TABLE IF EXISTS `event_repeat`;
CREATE TABLE `event_repeat` (
  `id` int(11) NOT NULL,
  `created_by_user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `interval_days` int(11) NOT NULL,
  `first_event` date DEFAULT NULL,
  `nd_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `event_review`
--

DROP TABLE IF EXISTS `event_review`;
CREATE TABLE `event_review` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL,
  `comment` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `forecast_weather`
--

DROP TABLE IF EXISTS `forecast_weather`;
CREATE TABLE `forecast_weather` (
  `id` int(11) NOT NULL,
  `city_name` varchar(25) DEFAULT NULL,
  `weather_main` varchar(15) DEFAULT NULL,
  `main_temp` decimal(4,2) DEFAULT NULL,
  `main_temp_feels_like` decimal(4,2) DEFAULT NULL,
  `visibility` int(11) DEFAULT NULL,
  `wind_speed` decimal(4,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `friend_request`
--

DROP TABLE IF EXISTS `friend_request`;
CREATE TABLE `friend_request` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `status` enum('pending','accepted','declined') DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp(),
  `responded_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `group`
--

DROP TABLE IF EXISTS `group`;
CREATE TABLE `group` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `image_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `group_member`
--

DROP TABLE IF EXISTS `group_member`;
CREATE TABLE `group_member` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `joined_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `image`
--

DROP TABLE IF EXISTS `image`;
CREATE TABLE `image` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `path` varchar(255) NOT NULL,
  `type` enum('profile','location','event','group','category') NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `location`
--

DROP TABLE IF EXISTS `location`;
CREATE TABLE `location` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `rating` decimal(2,1) DEFAULT 0.0,
  `group_id` int(11) DEFAULT NULL,
  `created_by_user_id` int(11) NOT NULL,
  `approved_status` enum('pending','approved','denied') DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `location_category`
--

DROP TABLE IF EXISTS `location_category`;
CREATE TABLE `location_category` (
  `id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `location_image`
--

DROP TABLE IF EXISTS `location_image`;
CREATE TABLE `location_image` (
  `id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `image_id` int(11) NOT NULL,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `location_review`
--

DROP TABLE IF EXISTS `location_review`;
CREATE TABLE `location_review` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL,
  `comment` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `organizerInfo`
--

DROP TABLE IF EXISTS `organizerInfo`;
CREATE TABLE `organizerInfo` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `image_id` int(11) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `rating` decimal(2,1) DEFAULT 0.0,
  `organizer_settings_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `organizer_review`
--

DROP TABLE IF EXISTS `organizer_review`;
CREATE TABLE `organizer_review` (
  `id` int(11) NOT NULL,
  `reviewer_id` int(11) DEFAULT NULL,
  `reviewed_id` int(11) DEFAULT NULL,
  `rating` tinyint(4) DEFAULT 0,
  `comment` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `organizer_settings`
--

DROP TABLE IF EXISTS `organizer_settings`;
CREATE TABLE `organizer_settings` (
  `id` int(11) NOT NULL,
  `settings_id` int(11) NOT NULL,
  `event_approved_notification` tinyint(4) DEFAULT 1,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `username` varchar(25) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `type` VARCHAR(255) DEFAULT "user",
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `userInfo`
--

DROP TABLE IF EXISTS `userInfo`;
CREATE TABLE `userInfo` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `image_id` int(11) DEFAULT NULL,
  `user_settings_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `user_favourite_event`
--

DROP TABLE IF EXISTS `user_favourite_event`;
CREATE TABLE `user_favourite_event` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `user_favourite_location`
--

DROP TABLE IF EXISTS `user_favourite_location`;
CREATE TABLE `user_favourite_location` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `user_settings`
--

DROP TABLE IF EXISTS `user_settings`;
CREATE TABLE `user_settings` (
  `id` int(11) NOT NULL,
  `settings_id` int(11) NOT NULL,
  `event_reminder` tinyint(4) DEFAULT 1,
  `new_event_notification` tinyint(4) DEFAULT 1,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `adminInfo`
--
ALTER TABLE `adminInfo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `admin_settings_id` (`admin_settings_id`);

--
-- A tábla indexei `admin_settings`
--
ALTER TABLE `admin_settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `settings_id` (`settings_id`);

--
-- A tábla indexei `base_settings`
--
ALTER TABLE `base_settings`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`id`),
  ADD KEY `image_id` (`image_id`);

--
-- A tábla indexei `current_weather`
--
ALTER TABLE `current_weather`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `event`
--
ALTER TABLE `event`
  ADD PRIMARY KEY (`id`),
  ADD KEY `location_id` (`location_id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `repeat_id` (`repeat_id`),
  ADD KEY `created_by_user_id` (`created_by_user_id`);

--
-- A tábla indexei `event_category`
--
ALTER TABLE `event_category`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `event_category_index_6` (`event_id`,`category_id`),
  ADD KEY `category_id` (`category_id`);

--
-- A tábla indexei `event_image`
--
ALTER TABLE `event_image`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event_id` (`event_id`),
  ADD KEY `image_id` (`image_id`);

--
-- A tábla indexei `event_participant`
--
ALTER TABLE `event_participant`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `event_participant_index_8` (`user_id`,`event_id`),
  ADD KEY `event_id` (`event_id`);

--
-- A tábla indexei `event_repeat`
--
ALTER TABLE `event_repeat`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `event_repeat_index_9` (`created_by_user_id`,`event_id`),
  ADD KEY `event_id` (`event_id`);

--
-- A tábla indexei `event_review`
--
ALTER TABLE `event_review`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `event_review_index_7` (`user_id`,`event_id`),
  ADD KEY `event_id` (`event_id`);

--
-- A tábla indexei `forecast_weather`
--
ALTER TABLE `forecast_weather`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `friend_request`
--
ALTER TABLE `friend_request`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `friend_request_index_3` (`sender_id`,`receiver_id`),
  ADD KEY `receiver_id` (`receiver_id`);

--
-- A tábla indexei `group`
--
ALTER TABLE `group`
  ADD PRIMARY KEY (`id`),
  ADD KEY `image_id` (`image_id`),
  ADD KEY `created_by` (`created_by`);

--
-- A tábla indexei `group_member`
--
ALTER TABLE `group_member`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `group_member_index_10` (`user_id`,`group_id`),
  ADD KEY `group_id` (`group_id`);

--
-- A tábla indexei `image`
--
ALTER TABLE `image`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `path` (`path`) USING HASH,
  ADD KEY `created_by` (`created_by`);

--
-- A tábla indexei `location`
--
ALTER TABLE `location`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `created_by_user_id` (`created_by_user_id`);

--
-- A tábla indexei `location_category`
--
ALTER TABLE `location_category`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `location_category_index_4` (`location_id`,`category_id`),
  ADD KEY `category_id` (`category_id`);

--
-- A tábla indexei `location_image`
--
ALTER TABLE `location_image`
  ADD PRIMARY KEY (`id`),
  ADD KEY `location_id` (`location_id`),
  ADD KEY `image_id` (`image_id`);

--
-- A tábla indexei `location_review`
--
ALTER TABLE `location_review`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `location_review_index_5` (`user_id`,`location_id`),
  ADD KEY `location_id` (`location_id`);

--
-- A tábla indexei `organizerInfo`
--
ALTER TABLE `organizerInfo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `image_id` (`image_id`),
  ADD KEY `organizer_settings_id` (`organizer_settings_id`);

--
-- A tábla indexei `organizer_review`
--
ALTER TABLE `organizer_review`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `organizer_review_index_0` (`reviewer_id`,`reviewed_id`),
  ADD KEY `reviewed_id` (`reviewed_id`);

--
-- A tábla indexei `organizer_settings`
--
ALTER TABLE `organizer_settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `settings_id` (`settings_id`);

--
-- A tábla indexei `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- A tábla indexei `userInfo`
--
ALTER TABLE `userInfo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `image_id` (`image_id`),
  ADD KEY `user_settings_id` (`user_settings_id`);

--
-- A tábla indexei `user_favourite_event`
--
ALTER TABLE `user_favourite_event`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_favourite_event_index_2` (`user_id`,`event_id`),
  ADD KEY `event_id` (`event_id`);

--
-- A tábla indexei `user_favourite_location`
--
ALTER TABLE `user_favourite_location`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_favourite_location_index_1` (`user_id`,`location_id`),
  ADD KEY `location_id` (`location_id`);

--
-- A tábla indexei `user_settings`
--
ALTER TABLE `user_settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `settings_id` (`settings_id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `adminInfo`
--
ALTER TABLE `adminInfo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `admin_settings`
--
ALTER TABLE `admin_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `base_settings`
--
ALTER TABLE `base_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `category`
--
ALTER TABLE `category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `current_weather`
--
ALTER TABLE `current_weather`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `event`
--
ALTER TABLE `event`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `event_category`
--
ALTER TABLE `event_category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `event_image`
--
ALTER TABLE `event_image`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `event_participant`
--
ALTER TABLE `event_participant`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `event_repeat`
--
ALTER TABLE `event_repeat`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `event_review`
--
ALTER TABLE `event_review`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `forecast_weather`
--
ALTER TABLE `forecast_weather`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `friend_request`
--
ALTER TABLE `friend_request`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `group`
--
ALTER TABLE `group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `group_member`
--
ALTER TABLE `group_member`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `image`
--
ALTER TABLE `image`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `location`
--
ALTER TABLE `location`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `location_category`
--
ALTER TABLE `location_category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `location_image`
--
ALTER TABLE `location_image`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `location_review`
--
ALTER TABLE `location_review`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `organizerInfo`
--
ALTER TABLE `organizerInfo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `organizer_review`
--
ALTER TABLE `organizer_review`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `organizer_settings`
--
ALTER TABLE `organizer_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `userInfo`
--
ALTER TABLE `userInfo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `user_favourite_event`
--
ALTER TABLE `user_favourite_event`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `user_favourite_location`
--
ALTER TABLE `user_favourite_location`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `user_settings`
--
ALTER TABLE `user_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `adminInfo`
--
ALTER TABLE `adminInfo`
  ADD CONSTRAINT `adminInfo_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `adminInfo_ibfk_2` FOREIGN KEY (`admin_settings_id`) REFERENCES `admin_settings` (`id`);

--
-- Megkötések a táblához `admin_settings`
--
ALTER TABLE `admin_settings`
  ADD CONSTRAINT `admin_settings_ibfk_1` FOREIGN KEY (`settings_id`) REFERENCES `base_settings` (`id`);

--
-- Megkötések a táblához `category`
--
ALTER TABLE `category`
  ADD CONSTRAINT `category_ibfk_1` FOREIGN KEY (`image_id`) REFERENCES `image` (`id`);

--
-- Megkötések a táblához `event`
--
ALTER TABLE `event`
  ADD CONSTRAINT `event_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`),
  ADD CONSTRAINT `event_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`),
  ADD CONSTRAINT `event_ibfk_3` FOREIGN KEY (`repeat_id`) REFERENCES `event_repeat` (`id`),
  ADD CONSTRAINT `event_ibfk_4` FOREIGN KEY (`created_by_user_id`) REFERENCES `user` (`id`);

--
-- Megkötések a táblához `event_category`
--
ALTER TABLE `event_category`
  ADD CONSTRAINT `event_category_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`),
  ADD CONSTRAINT `event_category_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

--
-- Megkötések a táblához `event_image`
--
ALTER TABLE `event_image`
  ADD CONSTRAINT `event_image_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`),
  ADD CONSTRAINT `event_image_ibfk_2` FOREIGN KEY (`image_id`) REFERENCES `image` (`id`);

--
-- Megkötések a táblához `event_participant`
--
ALTER TABLE `event_participant`
  ADD CONSTRAINT `event_participant_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `event_participant_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

--
-- Megkötések a táblához `event_repeat`
--
ALTER TABLE `event_repeat`
  ADD CONSTRAINT `event_repeat_ibfk_1` FOREIGN KEY (`created_by_user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `event_repeat_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

--
-- Megkötések a táblához `event_review`
--
ALTER TABLE `event_review`
  ADD CONSTRAINT `event_review_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `event_review_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

--
-- Megkötések a táblához `friend_request`
--
ALTER TABLE `friend_request`
  ADD CONSTRAINT `friend_request_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `friend_request_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `user` (`id`);

--
-- Megkötések a táblához `group`
--
ALTER TABLE `group`
  ADD CONSTRAINT `group_ibfk_1` FOREIGN KEY (`image_id`) REFERENCES `image` (`id`),
  ADD CONSTRAINT `group_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`);

--
-- Megkötések a táblához `group_member`
--
ALTER TABLE `group_member`
  ADD CONSTRAINT `group_member_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `group_member_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`);

--
-- Megkötések a táblához `image`
--
ALTER TABLE `image`
  ADD CONSTRAINT `image_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`);

--
-- Megkötések a táblához `location`
--
ALTER TABLE `location`
  ADD CONSTRAINT `location_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`),
  ADD CONSTRAINT `location_ibfk_2` FOREIGN KEY (`created_by_user_id`) REFERENCES `user` (`id`);

--
-- Megkötések a táblához `location_category`
--
ALTER TABLE `location_category`
  ADD CONSTRAINT `location_category_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`),
  ADD CONSTRAINT `location_category_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

--
-- Megkötések a táblához `location_image`
--
ALTER TABLE `location_image`
  ADD CONSTRAINT `location_image_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`),
  ADD CONSTRAINT `location_image_ibfk_2` FOREIGN KEY (`image_id`) REFERENCES `image` (`id`);

--
-- Megkötések a táblához `location_review`
--
ALTER TABLE `location_review`
  ADD CONSTRAINT `location_review_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `location_review_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`);

--
-- Megkötések a táblához `organizerInfo`
--
ALTER TABLE `organizerInfo`
  ADD CONSTRAINT `organizerInfo_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `organizerInfo_ibfk_2` FOREIGN KEY (`image_id`) REFERENCES `image` (`id`),
  ADD CONSTRAINT `organizerInfo_ibfk_3` FOREIGN KEY (`organizer_settings_id`) REFERENCES `organizer_settings` (`id`);

--
-- Megkötések a táblához `organizer_review`
--
ALTER TABLE `organizer_review`
  ADD CONSTRAINT `organizer_review_ibfk_1` FOREIGN KEY (`reviewer_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `organizer_review_ibfk_2` FOREIGN KEY (`reviewed_id`) REFERENCES `user` (`id`);

--
-- Megkötések a táblához `organizer_settings`
--
ALTER TABLE `organizer_settings`
  ADD CONSTRAINT `organizer_settings_ibfk_1` FOREIGN KEY (`settings_id`) REFERENCES `base_settings` (`id`);

--
-- Megkötések a táblához `userInfo`
--
ALTER TABLE `userInfo`
  ADD CONSTRAINT `userInfo_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `userInfo_ibfk_2` FOREIGN KEY (`image_id`) REFERENCES `image` (`id`),
  ADD CONSTRAINT `userInfo_ibfk_3` FOREIGN KEY (`user_settings_id`) REFERENCES `user_settings` (`id`);

--
-- Megkötések a táblához `user_favourite_event`
--
ALTER TABLE `user_favourite_event`
  ADD CONSTRAINT `user_favourite_event_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `user_favourite_event_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `event` (`id`);

--
-- Megkötések a táblához `user_favourite_location`
--
ALTER TABLE `user_favourite_location`
  ADD CONSTRAINT `user_favourite_location_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `user_favourite_location_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`);

--
-- Megkötések a táblához `user_settings`
--
ALTER TABLE `user_settings`
  ADD CONSTRAINT `user_settings_ibfk_1` FOREIGN KEY (`settings_id`) REFERENCES `base_settings` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
