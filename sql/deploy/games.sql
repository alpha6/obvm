-- Deploy obvm:games to sqlite

BEGIN;

CREATE TABLE `games` ( `game_id` INTEGER PRIMARY KEY AUTOINCREMENT, `game_title` TEXT NOT NULL, `game_archived` INTEGER DEFAULT 0 );

COMMIT;
