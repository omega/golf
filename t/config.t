#!/usr/bin/perl -w

use strict;
use Test::More tests => 1;

BEGIN {
    $ENV{GOLF_CONFIG_LOCAL_SUFFIX} = 'test';
}
use Golf::Config;

my $cfg = Golf::Config->config;

is($cfg->{test}, 1);


