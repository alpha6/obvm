-- Deploy obvm:game_mastres to sqlite

BEGIN;

CREATE TABLE `game_masters` (
    `link_id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `user_id` INTEGER NOT NULL,
    `game_id` INTEGER NOT NULL,
    `is_game_owner` Integer default 0,
    FOREIGN KEY(`user_id`) REFERENCES `users`(`user_id`),
    FOREIGN KEY(`game_id`) REFERENCES `games`(`game_id`)
);

COMMIT;
