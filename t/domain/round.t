#!/usr/bin/perl -w

use strict;
use Test::More 0.88;
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
    my $s = $D->new_scope;
    my $r = $D->find(Round => { id => $rid });
    is($r->course->name, "Ekeberg");
    is($r->id, $rid);
    ok($r->has_player('omega'), "we have player omega in this round");
    ok(!$r->has_player('absas'), "we don't have player absas in this round");
    
    # Lets try to update this round
    $D->update($r, {
        course => 'Ekeberg',
        players => ['seth', 'mesh']
    });
}
{
    my $s = $D->new_scope;
    my $r = $D->find(Round => { id => $rid });
    is($r->course->name, 'Ekeberg');
    is($r->date, '2009-05-22');
    ok($r->has_player('mesh'), "we have mesh in this round now");
    ok($r->has_player('seth'), "we have seth in this round now");
    ok(!$r->has_player('omega'), "we no longer have omega in this round");
    
    ok($D->lookup('user:seth')->has_round($r), "seth has this round");
    ok($D->lookup('user:mesh')->has_round($r), "mesh has this round");
    ok(!$D->lookup('user:omega')->has_round($r), "omega has not this round");
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
    is($r->holes_played, 1);
    is($r->get_player('omega')->total_score, 3);
    is($r->get_player('mesh')->total_score, 5);
    
    $r->add_hole_scores({
        omega => [4, 1],
        mesh => 3,
    });

    is($r->holes_played, 2);
    is($r->get_player('omega')->total_score, 7);
    is($r->get_player('mesh')->total_score, 8);
    
    $D->update($r, {
        course => 'Ekeberg',
        players => ['seth', 'mesh', 'omega']
    });
    
    is($r->get_player('omega')->total_score, 7);
    is($r->get_player('seth')->total_score, 0);
    is($r->get_player('mesh')->total_score, 8);
    
    ok($D->lookup('user:seth')->has_round($r), "seth has this round");
    ok($D->lookup('user:mesh')->has_round($r), "mesh has this round");
    ok($D->lookup('user:omega')->has_round($r), "omege has not this round");
    
}

done_testing();