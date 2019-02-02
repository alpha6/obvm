-- Deploy obvm:game_mastres to sqlite

BEGIN;

CREATE TABLE `game_masters` (
    `user_id` INTEGER NOT NULL,
    `game_id` INTEGER NOT NULL,
    FOREIGN KEY(`user_id`) REFERENCES `users`(`user_id`),
    FOREIGN KEY(`game_id`) REFERENCES `games`(`game_id`)
);

COMMIT;
