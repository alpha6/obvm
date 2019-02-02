-- Deploy obvm:game_characters to sqlite

BEGIN;

CREATE TABLE `game_characters` (
	`character_id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`character_name`	TEXT NOT NULL,
	`game_id`	INTEGER NOT NULL,
	`character_removed`	INTEGER DEFAULT 0
);

COMMIT;
