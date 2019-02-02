-- Deploy obvm:game_episodes to sqlite

BEGIN;

CREATE TABLE `game_episodes` (
	`episode_id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`game_id`	INTEGER NOT NULL,
	`episode_description`	TEXT NOT NULL,
	`episode_date`	TEXT NOT NULL,
	`episode_title`	TEXT
);

COMMIT;
