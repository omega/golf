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
    $c->log->debug('found course: ' . $p) if $c->debug;
    $c->stash( course =>  $p);
}

sub show : Chained('load') Args(0) PathPart('') {
    
}

sub chart : Chained('load') Args(0) PathPart('chart') {
    my ( $self, $c ) = @_;
    
    
    my $ignore = $c->req->params->{ignore};
    my @ignore = (ref $ignore ? @$ignore : (
        $ignore ? ($ignore) : ())
        );
    $c->log->debug('ignore: ' . join(", ", @ignore)) if $c->debug;
    
    my $players = {};

    my @rounds = $c->stash->{course}->rounds->members;
    foreach my $r (@rounds) {
        $c->log->debug('round: ' . $r) if $c->debug;
        foreach my $p ($r->players->members)  {
            my $pid = $p->player->id;
            $c->log->debug('  player: ' . $pid) if $c->debug;
            if (scalar(@ignore) and grep { $pid eq $_ } @ignore) {
                $c->log->debug('ignoring ' . $pid) if $c->debug;
                next;
            }
            $players->{$pid}->{n} = $pid;
            $players->{$pid}->{k} = scalar(keys(%$players)) 
                unless $players->{$pid}->{k};
            $players->{$pid}->{v}->{ ($p->total_score - $c->stash->{course}->par) }++;
        }
    }
    use Data::Dump qw/dump/;
    $c->log->debug('data: ' . dump($players)) if $c->debug;

    # rebuild $players into series
    my @series;
    my $ticks = {
        values => [],
        labels => [],
    };
    foreach my $p (values(%$players)) {
        my $s = { 
            name => $p->{n},
            keys => [],
            values => [],
            sizes => [],
        };
        my $k = $p->{k};
        
        push(@{ $ticks->{values} }, $k);
        push(@{ $ticks->{labels} }, $p->{n});
        
        
        foreach my $v (keys( %{ $p->{v} }) ) {
            my $n = $p->{v}->{$v};
            push(@{ $s->{keys} }, $k);
            push(@{ $s->{values} }, $v);
            push(@{ $s->{sizes} }, $n / 2);
        }
        
        push(@series, $s);
    }
    $c->log->debug(" series: \n\n" . dump(@series) . "\n\n") if $c->debug;
    $c->log->debug(" ticks: \n\n" . dump($ticks) . "\n\n") if $c->debug;
    $c->stash(
        current_view => 'Chart',
        data => {
            options => {
                height => 400,
            },
            serie_type => 'Series::Size',
            series => [ @series ],
            ticks => $ticks,
            
            chart => {
                type => 'Bubble',
            },
        },
    );

}
sub edit : Chained('load') Args(0) PathPart('edit') {
    my ($self, $c) = @_;
    
    $c->stash(template => 'course/course.tt');
    
    if ($c->req->method eq 'POST') {
        $c->log->debug('Gonna try to update the damn course :p') if $c->debug;
        
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
