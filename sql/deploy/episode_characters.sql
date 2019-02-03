-- Deploy obvm:episode_characters to sqlite

BEGIN;

CREATE TABLE `episode_characters` (
    `link_id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`episode_id`	INTEGER NOT NULL,
	`character_id`	INTEGER NOT NULL,
	FOREIGN KEY(`character_id`) REFERENCES `game_characters`(`character_id`),
	FOREIGN KEY(`episode_id`) REFERENCES `game_episodes`(`episode_id`)
);

COMMIT;
