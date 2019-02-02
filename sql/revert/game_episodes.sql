-- Revert obvm:game_episodes from sqlite

BEGIN;

DROP TABLE game_episodes;

COMMIT;
