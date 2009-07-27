#!/usr/bin/perl -w

use strict;
use Test::More 0.88;
use t::Test;
use Data::Dump qw/dump/;

my $cid;
{
    # create a course
    my $s = $D->new_scope;
    my $c = $D->create( 'Course' => { 
        name => 'Ekeberg',
        holes => [
            3, 3, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 3, 3, 3, 3,
        ],
    });
    
    is($c->size, 18);
    is($c->par, 56);
    $cid = $D->store($c);
}

{
    # create a one hole course
    my $s = $D->new_scope;
    my $c = $D->create( 'Course' => {
        name => 'SmallCourse',
        holes => 3
    });
    is($c->size, 1);
    is($c->par, 3);
    is($c->number_of_rounds, 0);
}

{
    my $s = $D->new_scope;
    my $c = $D->lookup($cid);
    is($c->name, "Ekeberg");
    
    # Check the damn holes?
    
    my @holes = $c->holes->members;
    isa_ok($holes[0], "Golf::Domain::Hole");
    is($c->get_hole(4)->par, 4);
    is($c->get_hole(4)->idx, 4);
    
}
{
    my $s = $D->new_scope;
    my $c = $D->find(Course => { name => 'Ekeberg' });
    isa_ok($c, "Golf::Domain::Course");
    is($c->name, "Ekeberg");
}
{
    my $s = $D->new_scope;
    my $c = $D->search({ name => 'Ekeberg' });
    my @all = $c->all;
    is(scalar(@all), 1);
}
{
    my $s = $D->new_scope;
    my $c = $D->find(Course => { name => 'Ekeberg' });
    
    $D->update($c, {
        name => 'Ekeberg', 
        holes => [
            4, 3, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 3, 3, 3, 3,
        ],
    });
    is($c->get_hole(1)->par, 4);
}