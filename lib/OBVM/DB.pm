package OBVM::DB;


use v5.20;
use strict;
use warnings;

use feature qw(signatures say);
no warnings qw(experimental::signatures);

use Data::Dumper;
use DBIx::Struct qw(connector);

use Mojo::Log;


my $log = Mojo::Log->new();

sub new {
    my $class = shift;
    my $db_file = shift;

    my $dbix = DBIx::Struct::connect(sprintf('dbi:SQLite:dbname=%s', $db_file),"","");



    my $self = {
        dbix_connector => $dbix,
    };
    bless $self, $class;
    return $self;
}

sub check_user ($self, $nickname, $password) {
    return one_row([users => -column => 'user_id'], { nickname => $nickname, password => $password });
}

sub get_user ($self, $user_id) {
    if ($user_id =~ /^\d+$/) {
        return $self->_get_user_by_user_id($user_id);
    } else {
        return $self->_get_user_by_username($user_id);
    }
}

sub _get_user_by_user_id ($self, $user_id) {
    my $row = one_row('users', {user_id => $user_id}) || return {};
    return $row->data(qw/user_id nickname fullname timestamp/)
}

sub _get_user_by_username($self, $username) {
    my $row = one_row('users', {nickname => $username}) || return {};
    return $row->data(qw/user_id nickname fullname timestamp/)
}


sub add_user($self, $username, $password, $fullname) {
    my $row = new_row('users', nickname => $username, password => $password, fullname => $fullname);
    return $row;
}

sub get_user_games($self, $user_id) {
    return all_rows([
        "games g" => -join => "game_masters gm",
        -columns  => ['g.*', 'gm.user_id']
    ],
        {'user_id' => $user_id}
    );
}

sub add_game($self, $game_title, $owner_id) {
    connector->txn(sub {
        my $game = new_row('games', game_title => $game_title)->data();
        new_row('game_masters', game_id => $game->{'game_id'}, user_id => $owner_id, is_game_owner => 1);

        $log->debug(sprintf("New game has added: %s %s owner is %s", $game->{'game_id'}, $game->{'game_title'}, $owner_id));
    });


}

sub get_game_info($self, $game_id, $user_id) {
    my $is_game_master = one_row(
        'game_masters', { user_id => $user_id, 'gm.game_id' => $game_id});
    if ($is_game_master) {
        my $masters = all_rows([
            'users u' => '-join' => 'game_masters gm',
            '-columns' => ['u.fullname']
        ], {'gm.user_id' => $user_id, 'gm.game_id' => $game_id}, sub { $_->data()});
        $log->debug(Dumper($masters));
    }
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