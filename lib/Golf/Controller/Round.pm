package Golf::Controller::Round;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Golf::Controller::Round - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

}

sub auto : Private {
    my ( $self, $c ) = @_;
    
    $c->stash(
        courses => $c->model('Kioku')->search({
            TYPE => 'Course'
        }),
    );
    $c->assets->include('static/js/round.js');
    
    return 1;
}
sub create : Local {
    my ( $self, $c ) = @_;


    if ($c->req->method eq 'POST') {

        $c->log->debug('POST recieved') if $c->debug;
        my $p = eval { 
            $c->model('Kioku')->model->create(Round => $c->req->params);
        };
        if ($@) {
            $c->stash( err => 'Error: ' . $@);
            $c->log->debug('Something went wrong with creating: ' . $@) 
                if $c->debug;
        } else {
            $c->flash( msg => 'Round created' );
            $c->res->redirect($c->uri_for('/round', $p->id));
            
        }
        
    }
    
    $c->stash(template => 'round/round.tt');
}

sub load : Chained('/') CaptureArgs(1) PathPart('round') {
    my ($self, $c, $id) = @_;
    my $p = $c->model('Kioku')->model->find('Round' => { id => $id });
    $c->log->debug('found round: ' . $p) if $c->debug;
    $c->stash( round =>  $p);
}

sub show : Chained('load') Args(0) PathPart('') {
    
}

sub edit : Chained('load') Args(0) PathPart('edit') {
    my ($self, $c) = @_;
    
    $c->stash(template => 'round/round.tt');
    
    if ($c->req->method eq 'POST') {
        $c->log->debug('Gonna try to update the damn course :p') if $c->debug;
        
        $c->model('Kioku')->model->update($c->stash->{round} => $c->req->params);
        
    }
}

=head1 AUTHOR

Andreas Marienborg

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
