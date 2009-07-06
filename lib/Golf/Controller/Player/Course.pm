package Golf::Controller::Player::Course;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Golf::Controller::Player::Course - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub list : Chained('/player/load') Args(0) PathPart('course') {
    my ( $self, $c ) = @_;
    
    # XXX: List all courses the player have played on.
    
    $c->stash(
        courses => $c->stash->{player}->courses,
    );
}

sub load : Chained('/player/load') CaptureArgs(1) PathPart('course') {
    my ( $self, $c, $name ) = @_;
    
    $c->stash(
        course => $c->model('Kioku')->model->find( Course => { name => $name } ),
        rounds => $c->stash->{player}->rounds_by_course_name($name),
    );
    
}

sub view : Chained('load') Args(0) PathPart('') {
}

sub chart : Chained('load') Args(0) PathPart('chart') {
    my ( $self, $c ) = @_;

    my $rounds = $c->stash->{rounds};
    
    my (@keys, @values);
    foreach my $r (@$rounds) {
        push(@keys, $r->date->epoch);
        push(@values, $r->get_player($c->stash->{player}->id)->total_score);
    }
    $c->log->debug('keys: ' . join(', ', @keys)) if $c->debug;
    $c->log->debug('vals: ' . join(', ', @values)) if $c->debug;

    $c->stash(
        current_view => 'Chart',
        data => {
            marker => {
                key => $keys[0],
                value => $c->stash->{course}->par,
            },
            series => [
                {
                    keys => \@keys,
                    values => \@values,
                    name => $c->stash->{player}->id,
                },
            ]
        },
    );
}

=head1 AUTHOR

Andreas Marienborg

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
