-- Revert obvm:episode_characters from sqlite

BEGIN;

DROP TABLE episode_characters;

COMMIT;
