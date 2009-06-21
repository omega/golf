#!/usr/bin/perl -w

use strict;
use Test::More tests => 15;
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
    is($r->id, $rid);
    ok($r->has_player('omega'), "we have player omega in this round");
    ok(!$r->has_player('absas'), "we don't have player absas in this round");
}

{
    my $s = $D->new_scope;
    my $r = $D->create(Round => {
        players => ['omega', 'mesh'],
        course => 'Ekeberg',
        date => '2009-05-23',
    });
    
    is(scalar(@{$r->players}), 2);
    {
        my $p = $r->get_player('omega');
        isa_ok($p, "Golf::Domain::PlayerRound");
        is($p->player->id, "omega");
    }
    $r->course('Frogner');
    
    is($r->course->name, "Frogner");
    
    # Add a score
    
    $r->add_hole_scores({
        omega => 3,
        mesh => 5,
    });
    is($r->_get_player(0)->count_scores, 1);
    is($r->get_player('omega')->total_score, 3);
    is($r->get_player('mesh')->total_score, 5);
    
    $r->add_hole_scores({
        omega => [4, 1],
        mesh => 3,
    });

    is($r->_get_player(0)->count_scores, 2);
    is($r->get_player('omega')->total_score, 7);
    is($r->get_player('mesh')->total_score, 8);
    
}
