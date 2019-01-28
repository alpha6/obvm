-- Deploy obvm:game_characters to sqlite

BEGIN;

create table game_characters
(
	character_id integer not null
		constraint game_characters_pk
			primary key autoincrement,
	character_name text not null,
	game_id integer not null
		constraint game_characters_games_game_id_fk
			references games,
	is_removed integer default 0
);

COMMIT;
