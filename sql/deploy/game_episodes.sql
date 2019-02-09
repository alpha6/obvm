-- Deploy obvm:game_episodes to sqlite

BEGIN;

CREATE TABLE `game_episodes` (
	`episode_id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`game_id`	INTEGER NOT NULL,
	`episode_description`	TEXT,
	`episode_date`	TEXT,
	`episode_title`	TEXT NOT NULL
);

COMMIT;
