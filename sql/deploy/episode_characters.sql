-- Deploy obvm:episode_characters to sqlite

BEGIN;

create table episode_characters
(
	episode_id integer not null
		constraint episode_characters_game_episodes_episode_id_fk
			references game_episodes,
	character_id integer not null
		constraint episode_characters_game_characters_character_id_fk
			references game_characters
);

COMMIT;
