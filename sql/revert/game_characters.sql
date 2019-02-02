-- Revert obvm:game_characters from sqlite

BEGIN;

DROP TABLE game_characters;

COMMIT;
