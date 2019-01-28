-- Deploy obvm:game_episodes to sqlite

BEGIN;

create table game_episodes
(
	episode_id integer not null
		constraint game_episodes_pk
			primary key autoincrement,
	game_id integer not null
		constraint game_episodes_games_game_id_fk
			references games,
	episode_description text not null,
	episode_date text not null,
	episode_title text
);
COMMIT;
