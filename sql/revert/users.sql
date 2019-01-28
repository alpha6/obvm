-- Revert obvm:users from sqlite

BEGIN;

DROP TABLE users;

COMMIT;
