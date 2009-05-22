#!/usr/bin/perl -w

use strict;
use Test::More tests => 2;
use t::Test qw(players courses);
use Golf::Domain::Search;

my $u = Golf::Domain::Search->coerce_player('omega');

isa_ok($u, "Golf::Domain::Player");


my $c = Golf::Domain::Search->coerce_course('Frogner');

isa_ok($c, "Golf::Domain::Course");
