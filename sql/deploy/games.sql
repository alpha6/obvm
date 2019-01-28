-- Deploy obvm:games to sqlite

BEGIN;

create table games
(
  game_id       integer
    constraint games_pk
      primary key autoincrement,
  game_title    text not null,
  game_archived integer default 0
);

create unique index games_game_title_uindex
  on games (game_title);

COMMIT;
