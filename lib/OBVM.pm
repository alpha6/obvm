package OBVM;
use lib 'lib';

use Mojo::Base 'Mojolicious';

use OBVM::DB;

# This method will run once at server start
sub startup {
    my $self = shift;

    my $log = Mojo::Log->new();

    # Load configuration from hash returned by "my_app.conf"
    my $config = $self->plugin('Config');

    my $db = OBVM::DB->new( $config->{'db_file'} );
    #Connecting to database
    $self->helper(db => sub {
        return $db;
    });

    my $auth = $self->plugin('authentication' => {
        autoload_user => 1,
        load_user     => sub {
            my $self = shift;
            my $uid  = shift;

            return $self->db->get_user($uid);
        },
        validate_user => sub {
            my $self      = shift;
            my $username  = shift || '';
            my $password  = shift || '';
            my $extradata = shift || {};

            my $user_id = $self->db->check_user( $username, $password );

            return $user_id;
        },
    }
    );


    # Router
    my $r = $self->routes;
    # my $auth_r = $r->under('/' => sub {
    #     my $c = shift;
    #     my $userinfo = $c->req->url->to_abs->userinfo;
    #     if ($self->is_user_authenticated) {
    #         $log->debug("Authenticated by plugin");
    #         return 1 ;
    #     } elsif ($userinfo) {
    #         $log->debug('Try basic auth');
    #         my ($user, $password) = split /:/, $userinfo , 2;
    #         $log->debug("$user - $password");
    #         my $res = $c->authenticate($user, $password);
    #         $log->debug("auth res $res");
    #         return $res;
    #     } else {
    #         return 0;
    #     }
        
    # });

    # Normal route to controller
    $r->get('/')->over(authenticated => 1)->to('main#index');
    $r->get('/')->over(authenticated => 0)->to('main#login_form');


    $r->get('/login')->over(authenticated => 0)->to('main#login_form');
    $r->post('/login')->to('main#login');
    $r->get('/logout')->over(authenticated => 1)->to('main#do_logout');

    $r->get('/register')->over(authenticated => 0)->to('main#register_form');
    $r->post('/register')->over(authenticated => 0)->to('main#register');

    $r->get('/games')->over(authenticated => 1)->to('main#games_list');

    $r->post('/game')->over(authenticated => 1)->to('main#add_game');
    $r->get('/game/:game_id')->over(authenticated => 1)->to('main#get_game_info');


    $r->post('/game/:game_id/character')->over(authenticated => 1)->to('main#add_character');
    $r->get('/game/:game_id/character/:character_id')->over(authenticated => 1)->to('main#get_character_info');

    $r->post('/game/:game_id/episode')->over(authenticated => 1)->to('main#add_episode');
    $r->get('/game/:game_id/episode/:episode_id')->over(authenticated => 1)->to('main#get_episode_info');


    $r->get('/*whatever')->over(authenticated => 1)->to('main#index');
    $r->get('/*whatever')->over(authenticated => 0)->to('main#login_form');

}

1;
