#!/usr/bin/perl -w

use strict;
use Test::More tests => 6;
use t::Test qw(courses players);

my $rid;

my $c = $D->find(Course => {name => 'Ekeberg'});
isa_ok($c, "Golf::Domain::Course");

my $omega = $D->find(Player => {name => 'Andreas Marienborg' });
my $mesh = $D->find(Player => { name => 'Øyvind Rogneslien' });
my $seth = $D->find(Player => { name => 'Andreas Nordseth' });


{
    my $s = $D->new_scope;
    my $r = $D->create(Round => {course => $c});
    is($r->course->name, $c->name);
    
    # Add some players
    $r->add_player($omega, $mesh, $seth);
    
    $rid = $D->store($r);
}

{
    my $s = $D->new_scope;
    my $r = $D->lookup($rid);
    isa_ok($r, "Golf::Domain::Round");
    is($r->course->name, $c->name);
    
    my @players = $r->all_players;
    is(scalar(@players), 3);
    is($players[0]->name, "Andreas Marienborg");
    
    
    # Lets add some scores
    
    $r->add_score(
        hole => 1,
        players => {
            $omega => 3,
            $mesh => 4,
            $seth => 3,
        }
    );
}