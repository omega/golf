package Golf::Controller::Course;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Golf::Controller::Course - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut
sub auto : Private {
    my ($self, $c) = @_;
    
    $c->assets->include('static/js/course.js');
    
    1;
}
sub index : Private {
    my ( $self, $c ) = @_;
    
    $c->stash(
        courses => $c->model('Kioku')->search({
            TYPE => 'Course'
        }),
    );
}

sub create : Local {
    my ( $self, $c ) = @_;


    if ($c->req->method eq 'POST') {

        $c->log->debug('POST recieved') if $c->debug;
        my $p = eval { 
            $c->model('Kioku')->model->create(Course => $c->req->params);
        };
        if ($@) {
            $c->stash( err => 'Error: ' . $@);
            $c->log->debug('Something went wrong with creating: ' . $@) 
                if $c->debug;
        } else {
            $c->flash( msg => 'Course created' );
            $c->res->redirect($c->uri_for('/course', $p->name ));
            
        }
        
    }
    
    $c->stash(template => 'course/course.tt');
}

sub load : Chained('/') CaptureArgs(1) PathPart('course') {
    my ($self, $c, $id) = @_;
    my $p = $c->model('Kioku')->model->find('Course' => { name => $id });
    $c->log->debug('found player: ' . $p) if $c->debug;
    $c->stash( course =>  $p);
}

sub show : Chained('load') Args(0) PathPart('') {
    
}

sub edit : Chained('load') Args(0) PathPart('edit') {
    my ($self, $c) = @_;
    
    $c->stash(template => 'course/course.tt');
    
    if ($c->req->method eq 'POST') {
        $c->log->debug('Gonna try to update the damn player :p') if $c->debug;
        
        $c->model('Kioku')->model->update($c->stash->{course} => $c->req->params);
        
    }
}

=head1 AUTHOR

Andreas Marienborg

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
