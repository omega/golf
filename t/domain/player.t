#!/usr/bin/perl -w

use strict;
use Test::More 0.88;
use t::Test;


my $pid;

{
    my $s = $D->new_scope;
    
    my $u = $D->create(Player => { 
        id => 'omega',
        name => 'Andreas Marienborg',
        password => 'a',
        cpassword => 'a',
    });
    
    my $pid = $D->store($u);
}

{
    my $s = $D->new_scope;
    
    my $u = $D->lookup("user:omega");
    is($u->name, "Andreas Marienborg");
}

{
    my $s = $D->new_scope;

    my $p = $D->find(Player => { name => 'Andreas Marienborg'} );
    isa_ok($p, "Golf::Domain::Player");
}

