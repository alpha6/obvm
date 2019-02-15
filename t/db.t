#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Data::Dumper;

use lib 'lib';
use OBVM::DB;

my $database_location = 'sql/obvm_dev.db';
my $user = 'alpha6';
my $password = 'password';
my $fullname = 'Test User';

my $test_game_name = 'Test Game';
my $episode_title = 'Test Episode One';

system('cd sql; sqitch revert -y; sqitch deploy');

subtest 'check db exists' => sub {
    is(-e $database_location, 1, 'DB exists');
    cmp_ok(-s $database_location, '>', 30000, 'Database is not empty');
};

my $db = OBVM::DB->new($database_location);

subtest 'db object creation' => sub {
    isa_ok($db, 'OBVM::DB', 'Object created');
    is($db->VERSION, 'v0.0.2', 'Version correct');
};



subtest 'add_user' => sub {
    my $new_user = $db->add_user($user, $password, $fullname);
    is($new_user->{'user_id'}, 1, 'User created');
    is($new_user->{'nickname'}, $user, 'Username ok');
    is($new_user->{'fullname'}, $fullname, 'Fullname ok');
};

subtest 'check_user' => sub {
    is($db->check_user($user, $password), 1, 'Check user is exists');
};

subtest 'get_user by username' => sub {
    my $user_data = $db->get_user($user);
    is ($user_data->{'user_id'}, 1, 'Check user_id');
    is ($user_data->{'nickname'}, $user, 'Username ok');
    is ($user_data->{'fullname'}, $fullname, 'Fullname ok');
};


subtest 'get_user by user id' => sub {
    my $user_data = $db->get_user(1);
    is ($user_data->{'user_id'}, 1, 'Check user_id');
    is ($user_data->{'nickname'}, $user, 'Username ok');
    is ($user_data->{'fullname'}, $fullname, 'Fullname ok');
};

subtest 'add_game' => sub {
    my $new_game = $db->add_game($test_game_name, 1);
    is($new_game->{'game_id'}, 1, 'Game_id is ok');
    is($new_game->{'game_title'}, $test_game_name, 'Game title is ok');
    is($new_game->{'owner_id'}, 1, 'Owner_id is ok');
};

{
    my $char_name = 'Test Character';

    subtest 'add_character' => sub {
        my $new_char = $db->add_character(1, $char_name);
        is($new_char->{'character_id'}, 1, 'Character_id is ok');
        is($new_char->{'character_name'}, $char_name, 'Character_name is ok');
    };

    subtest 'get_character' => sub {
        my $character = $db->get_character(1);
        is($character->{'character_id'}, 1, 'Character_id is ok');
        is($character->{'character_name'}, $char_name, 'Character_name is ok');
    };
}

subtest 'add_episode' => sub {
    my $new_episode = $db->add_episode(1, $episode_title);
    is($new_episode->{'episode_id'}, 1, 'Episode_id is ok');
    is($new_episode->{'episode_title'}, $episode_title, 'Episode_name is ok');
};

subtest 'get_episode' => sub {
    my $episode = $db->get_episode(1);
    is($episode->{'episode_title'}, $episode_title, 'Episode title is ok');
    is($episode->{'episode_description'}, undef, 'No description');
};

subtest 'get_game_info' => sub{
    my $game_info = $db->get_game_info(1, 1);
    is($game_info->{'masters'}[0]{'user_id'}, 1, 'has game master');
    is($game_info->{'masters'}[0]{'is_game_owner'}, 1, 'has game owner');
    is($game_info->{'episodes'}[0]{'episode_id'}, 1, 'Has episode');
    is($game_info->{'characters'}[0]{'character_id'}, 1, 'Has characters');
};

{
    my $episode_date = 'today';
    my $episode_title = 'Test Episode One Update';
    my $episode_description = 'It\'s a very long story...';

    subtest 'update_episode' => sub {

        my $episode = $db->update_episode(1, {episode_date => $episode_date, episode_title => $episode_title, episode_description => $episode_description});

        is($episode->{'episode_id'}, 1, 'Episode_id is ok');
        is($episode->{'episode_title'}, $episode_title, 'Title has updated');
        is($episode->{'episode_date'}, $episode_date, 'Episode_date is ok');
        is($episode->{'episode_description'}, $episode_description, 'Episode description has updated');
    };

    subtest 'check episode update' => sub {
        my $episode = $db->get_episode(1);
        is($episode->{'episode_title'}, $episode_title, 'Episode title is ok');
        is($episode->{'episode_description'}, $episode_description, 'Description is ok');
        is($episode->{'episode_date'}, $episode_date, 'Date is ok');
    };
}

{
    #add character to episode
    my $char_name = 'Character Two';

    subtest 'add_character' => sub {
        my $new_char = $db->add_character(1, $char_name);
        is($new_char->{'character_id'}, 2, 'Character_id is ok');
        is($new_char->{'character_name'}, $char_name, 'Character_name is ok');
    };

    subtest 'add_character_to_episode' => sub {
        $db->add_character_to_episode(1, 1);
        $db->add_character_to_episode(1, 2);
        my $episode = $db->get_episode(1);

        is($episode->{'episode_id'}, 1, 'Episode_id is ok');
        is(scalar @{$episode->{'involved_characters'}}, 2, 'Two characters has found for episode');
    };

    subtest 'remove_character_from_episode' => sub {

        $db->remove_character_from_episode(1, 1);
        my $episode = $db->get_episode(1);

        is($episode->{'episode_id'}, 1, 'Episode_id is ok');
        is(scalar @{$episode->{'involved_characters'}}, 1, 'One characters lasts for episode');
        is($episode->{'involved_characters'}[0]{'character_id'}, 2, 'Left the right character');
        is($episode->{'involved_characters'}[0]{'character_name'}, $char_name, 'Left the right character');
    };
}


{ #add and remove episode from game
    my $episode_date = '01.02.0003';
    my $episode_title = 'Episode Two';
    my $episode_description = 'It\'s a very long story...';
    my $target_episode_id = 2;

    subtest 'add_episode' => sub {
        my $new_episode = $db->add_episode(1, $episode_title);
        is($new_episode->{'episode_id'}, $target_episode_id, 'Episode_id is ok');
        is($new_episode->{'episode_title'}, $episode_title, 'Episode_name is ok');

        my $game_info = $db->get_game_info(1, 1);
        is($game_info->{'episodes'}[0]{'episode_id'}, 1, 'Game has two episodes');
    };

    subtest 'update_episode' => sub {

        my $episode = $db->update_episode(2, {episode_date => $episode_date, episode_description => $episode_description});

        is($episode->{'episode_id'}, $target_episode_id, 'Episode_id is ok');
        is($episode->{'episode_title'}, $episode_title, 'Title has updated');
        is($episode->{'episode_date'}, $episode_date, 'Episode_date is ok');
        is($episode->{'episode_description'}, $episode_description, 'Episode description has updated');
    };

    subtest 'check episode update' => sub {
        my $episode = $db->get_episode($target_episode_id);
        is($episode->{'episode_title'}, $episode_title, 'Episode title is ok');
        is($episode->{'episode_description'}, $episode_description, 'Description is ok');
        is($episode->{'episode_date'}, $episode_date, 'Date is ok');
    };

    subtest 'remove_episode' => sub {
        $db->remove_episode($target_episode_id);
        my $game_info = $db->get_game_info(1, 1);
        is($game_info->{'episodes'}[0]{'episode_id'}, 1, 'Has one episode now');

    };
}

{ #add and remove game master
    my $user = 'second_user';
    my $password = 'password';
    my $fullname = 'Second Master';
    my $desired_user_id = 2;
    my $game_id = 1;

    subtest 'add_user' => sub {
        my $new_user = $db->add_user($user, $password, $fullname);
        is($new_user->{'user_id'}, $desired_user_id, 'User created');
        is($new_user->{'nickname'}, $user, 'Username ok');
        is($new_user->{'fullname'}, $fullname, 'Fullname ok');
    };

    subtest 'check has no games' => sub {
      my $games = $db->get_user_games($desired_user_id);
        is(scalar @$games, 0, 'No games found');
    };

    subtest 'add master to game' => sub {
        $db->add_master($game_id, $desired_user_id);
        my $games = $db->get_user_games($desired_user_id);
        is(scalar $games->[0]{'game_id'}, $game_id, 'Game found for user');
        is(scalar $games->[0]{'is_game_owner'}, 0, 'Not owner');
        is(scalar $games->[0]{'user_id'}, $desired_user_id, 'Correct user id');
    };
}

done_testing();

