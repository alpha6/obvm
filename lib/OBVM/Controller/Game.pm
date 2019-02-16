package OBVM::Controller::Game;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use strict;
use warnings FATAL => 'all';

sub get_characters {
    my $self = shift;
    my $game_id = $self->param('game_id');

    $self->render(json => $self->db->get_game_characters($game_id));
}

sub get_episodes {
    my $self = shift;

    my $game_id = $self->param('game_id');

    $self->render(json => $self->db->get_game_episodes($game_id));
}

sub get_episode_info {
    my $self = shift;
    my $game_id = $self->param('game_id');
    my $episode_id = $self->param('episode_id');

    my $episode_info = $self->db->get_episode($episode_id);

    $self->log->debug(Dumper($episode_info));

    $self->render( episode_info => $episode_info);
}

1;