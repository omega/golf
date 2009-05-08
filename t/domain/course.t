#!/usr/bin/perl -w

use strict;
use Test::More tests => 5;
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
    my $s = $D->new_scope;
    my $c = $D->lookup($cid);
    is($c->name, "Ekeberg");
    
    # Check the damn holes?
    
    my @holes = $c->holes;
    diag(dump(@holes));
    isa_ok($holes[0], "Golf::Domain::Hole");
    is($holes[3]->par, 4);
    
}