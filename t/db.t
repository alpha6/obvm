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

subtest 'add_character' => sub {
    my $char_name = 'Test Character';
    my $new_char = $db->add_character(1, $char_name);
    is($new_char->{'character_id'}, 1, 'Character_id is ok');
    is($new_char->{'character_name'}, $char_name, 'Character_name is ok');
};


subtest 'add_episode' => sub {
    my $episode_title = 'Test Episode One';
    my $new_episode = $db->add_episode(1, $episode_title);
    is($new_episode->{'episode_id'}, 1, 'Episode_id is ok');
    is($new_episode->{'episode_title'}, $episode_title, 'Episode_name is ok');
};


done_testing();

