#!/usr/bin/perl -w

use strict;
use Test::More tests => 2;
use t::Test qw(courses players);

my $rid;

{
    my $s = $D->new_scope;
    my $r = $D->create(Round => {
        players => 'omega',
        course => 'Ekeberg',
        date => '2009-05-22',
    });
    
    isa_ok($r, "Golf::Domain::Round");
    $rid = $r->id;
}
{
    my $r = $D->find(Round => { id => $rid });
    is($r->course->name, "Ekeberg");
}