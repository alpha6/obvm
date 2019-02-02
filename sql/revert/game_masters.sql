-- Revert obvm:game_mastres from sqlite

BEGIN;

DROP TABLE game_masters;

COMMIT;
