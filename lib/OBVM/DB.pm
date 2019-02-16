package OBVM::DB;


use v5.20;
use strict;
use warnings;

our $VERSION = version->declare('v0.0.2');

use feature qw(signatures say);
no warnings qw(experimental::signatures);

use Data::Dumper;
use DBIx::Struct qw(connector);
use Digest::SHA;

use Mojo::Log;


sub new {
    my $class = shift;
    my $db_file = shift;

    DBIx::Struct::connect(sprintf('dbi:SQLite:dbname=%s', $db_file),"","");

    no strict 'refs';
    for (keys %DBC::) {
        say STDERR "$_";
    }
    use strict 'refs';

    my $self = {};
    bless $self, $class;
    return $self;
}

sub check_user ($self, $nickname, $password) {
    my $digest = $self->_gen_hash($password);
    return one_row([users => -column => 'user_id'], { nickname => $nickname, password => $digest->hexdigest() });
}

sub get_user ($self, $user_id) {
    if ($user_id =~ /^\d+$/) {
        return $self->_get_user_by_user_id($user_id);
    } else {
        return $self->_get_user_by_username($user_id);
    }
}

sub _get_user_by_user_id ($self, $user_id) {
    die("user_id should be a number!") unless ($user_id =~ /\d+/);

    return one_row('users', {user_id => $user_id})->data(qw/user_id nickname fullname timestamp/);
}

sub _get_user_by_username($self, $username) {
    die("user_id should be a simple scalar!") unless (ref $username eq '');

    return one_row('users', {nickname => $username})->data(qw/user_id nickname fullname timestamp/);

}


sub add_user($self, $username, $password, $fullname) {
    my $digest = $self->_gen_hash($password);
    return new_row('users', nickname => $username, password => $digest->hexdigest(), fullname => $fullname)->data(qw/user_id nickname fullname timestamp/);
}

sub get_user_games($self, $user_id) {
    die("user_id should be a number!") unless ($user_id =~ /\d+/);

    return all_rows([
        "games g" => -join => "game_masters gm",
        -columns  => ['g.*', 'gm.user_id', 'gm.is_game_owner' ]
    ],
        {'user_id' => $user_id},
        sub {$_->data()}
    );
}

sub add_game($self, $game_title, $owner_id) {
    die("owner_id should be a number!") unless ($owner_id =~ /\d+/);

    my $game;
    connector->txn(sub {
        $game = new_row('games', game_title => $game_title)->data();
        my $mapping = new_row('game_masters', game_id => $game->{'game_id'}, user_id => $owner_id, is_game_owner => 1)->data();
        $game->{'owner_id'} = $mapping->{'user_id'};
    });

    return $game;
}

sub add_master($self, $game_id, $user_id) {
    die("user_id should be a number!") unless ($user_id =~ /\d+/);
    die("game_id should be a number!") unless ($game_id =~ /\d+/);

    return new_row('game_masters', game_id => $game_id, user_id => $user_id)->data();
}

sub get_game_info($self, $game_id, $user_id) {
    die("user_id should be a number!") unless ($user_id =~ /\d+/);
    die("game_id should be a number!") unless ($game_id =~ /\d+/);

    my $is_game_master = one_row(
        'game_masters', { user_id => $user_id, 'game_id' => $game_id});

    if ($is_game_master) {
        my $masters = all_rows([
            'users u' => '-join' => 'game_masters gm',
            '-columns' => ['u.user_id, u.fullname', 'gm.is_game_owner']
        ], {'u.user_id' => $user_id, 'gm.game_id' => $game_id}, sub{$_->data()});

        my $episodes = $self->get_game_episodes($game_id);
        my $characters = $self->get_game_characters($game_id);

        return { masters => $masters, episodes => $episodes, characters => $characters};
    }
}

sub get_game_episodes($self, $game_id) {
    return all_rows('game_episodes', { 'game_id' => $game_id }, sub{$_->data()});
}

sub get_game_characters($self, $game_id) {
    return all_rows('game_characters', { 'game_id' => $game_id}, sub{$_->data()});
}

sub add_character($self, $game_id, $character_name) {
    die ("game_id should be a number!") unless ($game_id =~ /\d+/);

    return new_row('game_characters', game_id => $game_id, character_name => $character_name)->data();
}

sub get_character($self, $character_id) {
    die ("character_id should be a number!") unless ($character_id =~ /\d+/);
    return one_row('game_characters', $character_id)->data();
}

sub add_episode($self, $game_id, $episode_title) {
    die ("game_id should be a number!") unless ($game_id =~ /\d+/);

    return new_row('game_episodes', game_id => $game_id, episode_title => $episode_title)->data();
}

sub remove_episode($self, $episode_id) {
    die("episode_id should be a number!") unless ($episode_id =~ /\d+/);

    connector->txn(sub {
        DBC::EpisodeCharacters->delete({ episode_id => $episode_id});
        DBC::GameEpisodes->delete({ episode_id => $episode_id });
    });
    return;

}

sub add_character_to_episode($self, $episode_id, $character_id) {
    die ("episode_id should be a number!") unless ($episode_id =~ /\d+/);
    die ("character_id should be a number!") unless ($character_id =~ /\d+/);

    new_row('episode_characters', episode_id => $episode_id,  character_id => $character_id);
    return;
}

sub remove_character_from_episode($self, $episode_id, $character_id) {
    die ("episode_id should be a number!") unless ($episode_id =~ /\d+/);
    die ("character_id should be a number!") unless ($character_id =~ /\d+/);

    DBC::EpisodeCharacters->delete({episode_id => $episode_id,  character_id => $character_id});
    return;
}

sub get_episode($self, $episode_id) { #Returns episode info with involved characters
    die ("episode_id should be a number!") unless ($episode_id =~ /\d+/);

    my $episode_data = one_row('game_episodes', $episode_id)->data();
    my $involved_characters = all_rows([
        'episode_characters ec' => '-join' => 'game_characters gc',
        '-columns'              => ['gc.character_name, gc.character_id']
    ], {episode_id => $episode_id}, sub { $_->data()});
    $episode_data->{'involved_characters'} = $involved_characters;

    return $episode_data;
}

sub update_episode($self, $episode_id, $episode_data) {
    my $episode = one_row('game_episodes', $episode_id);

    $episode->episode_description($episode_data->{'episode_description'}) if defined $episode_data->{'episode_description'};
    $episode->episode_date($episode_data->{'episode_date'}) if defined $episode_data->{'episode_date'};
    $episode->episode_title($episode_data->{'episode_title'}) if defined $episode_data->{'episode_title'};
    $episode->update;

    return $self->get_episode($episode_id);
}

sub _gen_hash($self, $src) {
        state $sha = Digest::SHA->new('sha256');
        return $sha->add($src);
}

# sub save_tag($self, $db_file_id, $tag_name, $tag_value) {
#     eval {
#         my $row = new_row('exif_data', 'exif_tag' => $tag_name, 'tag_data' => $tag_value,'image_id' => $db_file_id, deleted => 0) || die "error!";
#         return $row;
#     };
#     if ($@) {
#       say STDERR ("Error! $@");
#     }
# }
#
# sub save_tags($self, $db_file_id, $tag_data) {
#     eval {
#         connector->txn(sub {
#             for my $key (keys %$tag_data) {
#                 $self->save_tag($db_file_id, $key, $tag_data->{$key});
#             }
#         });
#     };
#     if ($@) {
#         say STDERR ("Error! $@");
#     }
#
# }


1;