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

sub auto : Private {
    my ( $self, $c ) = @_;
    
    $c->stash(
        courses => $c->model('Kioku')->search({
            TYPE => 'Course'
        }),
        players => $c->model('Kioku')->search({
            TYPE => 'Player'
        }),
    );
    $c->assets->include('static/js/round.js');
    
    return 1;
}

sub index : Private {
    my ( $self, $c ) = @_;
    $c->stash( rounds => $c->model('Kioku')->search({
        TYPE => 'Round',
    }));
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
        $c->log->debug('Gonna try to update the damn round :p') if $c->debug;
        # XXX: this will have to be more manual or based on some method naming 
        # convention
        $c->model('Kioku')->model->update(
            $c->stash->{round} => $c->req->params
        );
        
    }
}


sub add_score : Chained('load') Args(0) {
    my ($self, $c) = @_;
    
    # build the hash
    
    my @players = grep { /^p_[a-z]+$/ } keys( %{$c->req->params} );
    
    my $scores = {};
    
    foreach my $p (@players) {
        my ($id) = ($p =~ m/p_(.*)/);
        $scores->{$id} = $c->req->params->{$p};
    }
    use Data::Dump qw/dump/;
    $c->log->debug('scores: ' . dump($scores)) if $c->debug;
    $c->stash->{round}->add_hole_scores($scores);
    
    $c->model('Kioku')->model->store($c->stash->{round});
    
    $c->res->redirect($c->uri_for_action(
        $self->action_for('show'), $c->req->captures)
    );
    
}

=head1 AUTHOR

Andreas Marienborg

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
