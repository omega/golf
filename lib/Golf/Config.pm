package Golf::Config;


use Config::JFDI;

use Data::Dump qw/dump/;
use Path::Class::File;
use Path::Class::Dir;

sub config {
    my $path = $INC{'Golf/Config.pm'};
    my $dir = Path::Class::File->new($path)->dir->relative;
    
    while ($dir =~ m/lib/) {
        $dir = $dir->parent;
    }
    my $config = Config::JFDI->new(name => 'Golf', path => $dir );
    
    return $config->get;
}

1;
