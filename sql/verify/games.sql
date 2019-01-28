-- Verify obvm:games on sqlite

BEGIN;

SELECT game_id, game_title, game_archived
      FROM games
 WHERE 0;

ROLLBACK;
