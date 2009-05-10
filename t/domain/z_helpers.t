#!/usr/bin/perl -w

use strict;
use Test::More tests => 5;
use Test::Exception;
use t::Test;


{
    # Create a new player
    my $s = $D->new_scope;
    my $p = $D->create_player({
        id => 'omega',
        name => 'Andreas Marienborg',
        description => 'Just another perl-hacking discgolfer',
        password => 'blabla',
        cpassword => 'blabla',
    });
    isa_ok($p, "Golf::Domain::Player");
    ok($p->check_password('blabla'), "can check the password");
    
    throws_ok {
        $D->create_player({
            id => 'apejens',
            name => 'ape jens',
            password => 'jens',
        });
    } qr/Password and cpassword/, "we throw an error on creating with bad cpw";

    throws_ok {
        $D->create_player({
        });
    } qr/need id column/, "we throw an error on creating with missing id";
    
    
    my $stream = $D->search({TYPE => 'Player'});
    while ( my $block = $stream->next ) {
        foreach my $player (@$block) {
            isa_ok($player, "Golf::Domain::Player");
        }
    }
}
