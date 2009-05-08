package
t::Test;

use strict; 
use warnings;
use Golf::Domain;
use File::Path;

our $D;

sub import {
    my ($exp, @imports) = @_;
    # create the db
    $D = Golf::Domain->new(dsn => 'bdb:dir=t/db', extra_args => { create => 1 });
    # deploy some data?
    
    foreach my $i ( @imports ) {
        if (my $f = __PACKAGE__->can("import_" . $i)) {
            $f->();
        }
    }
    
    {
        my ($c, $f, $n) = caller();
        
        no strict 'refs';
        *{ $c . '::D' } = \${ $exp . '::D'};
        
    }
}

sub import_players {
    import_helper( Player => 
        {
            name => 'Andreas Marienborg',
            password => '',
            id => 'omega',
        },
        {
            name => 'Andreas Nordseth',
            password => '',
            id => 'seth',
        },
        {
            name => 'Øyvind Rogneslien',
            password => '',
            id => 'mesh',
        },
        
    );
}
sub import_courses {
    
    import_helper( Course => 
        {
            name => 'Ekeberg',
            holes => [
                3, 3, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 3, 3, 3, 3,
            ],
        },
        {
            name => 'Frogner',
            holes => [
                3, 3, 3, 3, 3, 3, 3, 3, 3,
            ]
        },
        {
            name => 'Muselunden',
            holes => [
                3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
            ]
        },
        
    );
    
}

sub import_helper {
    my $class = shift;
    my $s = $D->new_scope;
    foreach my $c (@_) {
        $D->store($D->create( $class => $c));
    }
    
}

sub END {
    
    warn "# CLEANUP";
    # cleanup, oh yeah :)
    
    File::Path::rmtree('t/db');
    
}
1;
