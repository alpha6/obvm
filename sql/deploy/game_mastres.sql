-- Deploy obvm:game_mastres to sqlite

BEGIN;

create table game_masters
(
  user_id integer not null
    references users,
  game_id integer not null
    references games
);

COMMIT;
