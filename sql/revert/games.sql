-- Revert obvm:games from sqlite

BEGIN;

drop table games;

COMMIT;
