#!/usr/bin/perl -w

use strict;
use Test::More tests => 1;
use t::Test;


my $pid;

{
    my $s = $D->new_scope;
    
    my $u = $D->create(Player => { 
        id => 'omega',
        name => 'Andreas Marienborg',
        password => ''
    });
    
    my $pid = $D->store($u);
}

diag(" UID: " . $pid);

{
    my $s = $D->new_scope;
    
    my $u = $D->lookup("user:omega");
    is($u->name, "Andreas Marienborg");
}