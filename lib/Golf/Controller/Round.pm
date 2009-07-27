package Golf::Controller::Round;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Scalar::Util qw/looks_like_number/;

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
            
            
            $c->forward('handle_scores', [$p]);
            
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
sub delete : Chained('load') Args(0) PathPart('delete') {
    my ($self, $c) = @_;
    $c->model('Kioku')->model->remove($c->stash->{round});
    $c->res->redirect($c->uri_for_action(
        $self->action_for('index'))
    );
    
}
sub edit : Chained('load') Args(0) PathPart('edit') {
    my ($self, $c) = @_;
    
    $c->stash(template => 'round/round.tt');
    
    if ($c->req->method eq 'POST') {
        $c->log->debug('Gonna try to update the damn round :p') if $c->debug;
        my $round = $c->stash->{round};
        
        $round->update($c->req->params);
        
        $c->forward('handle_scores', [$round]);
        $c->res->redirect($c->uri_for_action(
            $c->action, $c->req->captures
        ));
        
    }
}


sub handle_scores : Private {
    my ( $self, $c, $round ) = @_;
    
    # work trough the post params and set hole scores
    foreach my $hole ($round->course->holes->members) {
        $c->log->debug('hole #' . $hole->idx) if $c->debug;
        my $i = $hole->idx;
        my $scores = {};
        
        foreach my $pr ($round->players->members) {
            $c->log->debug('   player ' . $pr->player->id) if $c->debug;
            my $score = $c->req->params->{$i . "_" . $pr->player->id};
            
            $scores->{ $pr->player->id } = $score 
                if looks_like_number($score) || ref($score);
            
        }
        
        $round->set_hole_scores($hole, $scores);
    }
    
    $c->model('Kioku')->model->directory->store($round);
    
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
