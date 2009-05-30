#!/usr/bin/perl

use Config::Any;

use lib qw(lib);

my $cfg = Config::Any->load_files({ files => [qw/golf.yml/], use_ext => 1})
->[0]->{'golf.yml'}->{'Model::Kioku'};

use Data::Dump qw/dump/;

use Golf::Domain;


my $d = Golf::Domain->new(%$cfg);

my $t = shift;

my $q = {
#    TYPE => $t
};

if (scalar(@ARGV)) {
    my $k = shift;
    $q->{$k} = shift;
}
warn "doing search on " . dump($q);
my $res = $d->search($q);

warn "search done, fetching results";

die "no results" unless $res;
my @res = eval {$res->all};
die "error fetchin: " . dump($@) if ($@);
warn "found " . scalar(@res) . " results";
foreach my $r (@res) {
    warn "res: $r";
    warn dump($r);
}