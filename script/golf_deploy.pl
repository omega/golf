#!/usr/bin/perl

use lib qw(lib);

use Data::Dump qw/dump/;

use Golf::Config;

my $cfg = Golf::Config->config->{'Model::Kioku'};


use Golf::Domain;
warn "loaded code and config";

my $d = Golf::Domain->new(%$cfg, extra_args => { create => 1 } );

warn "deployed to $d";