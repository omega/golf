package Golf::Controller::Player;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Golf::Domain::Player;

=head1 NAME

Golf::Controller::Player - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    
    $c->stash(
        players => [$c->model('Kioku')->search({
            TYPE => 'Player'
        })->all],
    );
}

sub create : Local {
    my ( $self, $c ) = @_;


    if ($c->req->method eq 'POST') {

        $c->log->debug('POST recieved') if $c->debug;
        my $p = eval { 
            $c->model('Kioku')->model->create_player($c->req->params);
        };
        if ($@) {
            $c->stash( err => 'Error: ' . $@);
            $c->log->debug('Something went wrong with creating: ' . $@) 
                if $c->debug;
        } else {
            $c->flash( msg => 'User created' );
            $c->res->redirect($c->uri_for('/player', $p->id ));
            
        }
        
    }
    
    $c->stash(template => 'player/player.tt');
}

sub load : Chained('/') CaptureArgs(1) PathPart('player') {
    my ($self, $c, $id) = @_;
    my $p = $c->model('Kioku')->lookup('user:' . $id);
    $c->log->debug('found player: ' . $p) if $c->debug;
    $c->stash( player =>  $p);
}

sub show : Chained('load') Args(0) PathPart('') {
    
}

sub edit : Chained('load') Args(0) PathPart('edit') {
    my ($self, $c) = @_;
    
    $c->stash(template => 'player/player.tt');
}


=head1 AUTHOR

Andreas Marienborg

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
