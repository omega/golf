#!/usr/bin/perl

use Config::Any;

use lib qw(lib);

my $cfg = Config::Any->load_files({ files => [qw/golf.yml/], use_ext => 1})
->[0]->{'golf.yml'}->{'Model::Kioku'};

use Data::Dump qw/dump/;

use Golf::Domain;


my $d = Golf::Domain->new(%$cfg);


warn dump($d->find(shift, {shift, shift}));