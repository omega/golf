#!/usr/bin/perl

use Config::Any;

use lib qw(lib);

use Data::Dump qw/dump/;

my $cfg = Config::Any->load_files({ files => [qw/golf.yml golf_local.yml/], use_ext => 1});


my $dsn;

foreach (@$cfg) {
    if ($_->{'golf.yml'} and !$dsn) {
        # not seen local, setting $dsn
        $dsn = $_->{'golf.yml'}->{'Model::Kioku'};
    } elsif ($_->{'golf_local.yml'}) {
        $dsn = $_->{'golf_local.yml'}->{'Model::Kioku'} if $_->{'golf_local.yml'}->{'Model::Kioku'};
    }
}



use Golf::Domain;


my $d = Golf::Domain->new(%$dsn, extra_args => { create => 1 } );