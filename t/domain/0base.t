#!/usr/bin/perl -w

use strict;
use Test::More tests => 1;
use t::Test;

isa_ok($D, "Golf::Domain");

