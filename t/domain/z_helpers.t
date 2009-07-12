#!/usr/bin/perl -w

use strict;
use Test::More 0.88;
use Test::Exception;
use t::Test;


{
    # Create a new player
    my $s = $D->new_scope;
    my $p = $D->create( Player => {
        id => 'omega',
        name => 'Andreas Marienborg',
        description => 'Just another perl-hacking discgolfer',
        password => 'blabla',
        cpassword => 'blabla',
    });
    isa_ok($p, "Golf::Domain::Player");
    ok($p->check_password('blabla'), "can check the password");
    
    throws_ok {
        $D->create( Player => {
            id => 'apejens',
            name => 'ape jens',
            password => 'jens',
        });
    } qr/Password and cpassword/, "we throw an error on creating with bad cpw";

    throws_ok {
        $D->create( Player => {
        });
    } qr/need id column/, "we throw an error on creating with missing id";
    
    
    my $stream = $D->search({TYPE => 'Player'});
    while ( my $block = $stream->next ) {
        foreach my $player (@$block) {
            isa_ok($player, "Golf::Domain::Player");
        }
    }
    
    my $course = $D->create(Course => {
        name => 'Ekeberg',
        holes => [3,4,5,1,2],
    });
    isa_ok($course, "Golf::Domain::Course");
    is($course->par, 15);
    my $round = $D->create( Round => {
        course => $course,
        players => $p,
        date => '2009-05-22',
    });
    
    
    my $frogner = $D->create(Course => {
        name => 'Frogner',
        holes => [3,4,1,3],
    });
    
    $D->update($round => { course => 'Frogner' });
    
    is($round->course->name, "Frogner");
    is($D->search({TYPE => 'Round'})->all, 1);
}
{
    my $s = $D->new_scope;
    
    my $c = $D->find(Round => {course => "Frogner"});
    is($c->course->par, 11)
}
