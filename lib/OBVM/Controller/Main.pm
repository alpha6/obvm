package OBVM::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

# This action will render a template
sub index {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
}

sub login_form {
    my $self = shift;
    # if ($self->basic_auth) {
    #     say STDERR "Basic call!";
    # } else {
    #     say STDERR "no auth call!";
    # }
    # shift->render(status => 401);
}

sub login {
    my $self = shift;
    my $u    = $self->req->param('username');
    my $p    = $self->req->param('password');

    if ( $self->authenticate( $u, $p ) ) {
        $self->redirect_to('/');
    }
    else {
        $self->render( text => 'Login failed :(' );
    }

}

sub do_logout {
    my $self = shift;

    $self->logout();
    $self->render( template => 'login_form' );
}

sub register_form {

}

sub register {
    my $self     = shift;
    my $username = $self->req->param('username') || "";
    my $password = $self->req->param('password') || "";
    my $fullname = $self->req->param('fullname') || "";
    my $invite   = $self->req->param('invite') || "";

    if ( $invite eq $self->config->{'invite_code'} ) {

        #chek that username is not taken
        my $user = $self->db->get_user($username);
        if ( $user->{'user_id'} > 0 ) {
            $self->render(
                template => 'error',
                message  => 'Username already taken!'
            );
            return 0;
        }

        if ( $fullname eq '' ) {
            $fullname = $username;
        }

        my $digest = $self->gen_hash($password);
        $self->db->add_user( $username, $digest->hexdigest(), $fullname );

        #Authenticate user after add
        if ( $self->authenticate( $username, $password ) ) {
            $self->redirect_to('/');
        }
        else {
            $self->render( template => 'error', message => 'Login failed :(' );
        }

    }
    else {
        $self->render( template => 'error', message => 'invalid invite code' );
    }
};


sub games_list {
    my $self = shift;
    my $current_user = $self->current_user();

    my $user_games = $self->db->get_user_games($current_user->{'user_id'});

    $self->render( games_list => $user_games);
}

sub add_game {
    my $self = shift;
    my $game_title = $self->req->param('game_title');
    my $owner_id = $self->current_user()->{'user_id'};
    my $res = $self->db->add_game($game_title, $owner_id);
    $self->redirect_to('/games');
}

sub get_game_info {
    my $self = shift;
    my $game_id = $self->param('game_id');
    my $current_user = $self->current_user();

    my $game = $self->db->get_game_info($game_id, $current_user->{'user_id'});

    $self->render(game_data => $game);
}

1;
