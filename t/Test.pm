package
t::Test;

use strict; 
use warnings;
use Golf::Domain;
use File::Path;

our $D;

sub import {
    my ($exp, @imports) = @_;
    
    $ENV{GOLF_DSN} = 'bdb-gin:dir=t/db';
    # create the db
    $D = Golf::Domain->new(dsn => 'bdb-gin:dir=t/db', extra_args => { create => 1 });
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
            password => 'a',
            cpassword => 'a',
            id => 'omega',
        },
        {
            name => 'Andreas Nordseth',
            password => 'a',
            cpassword => 'a',
            id => 'seth',
        },
        {
            name => 'Øyvind Rogneslien',
            password => 'a',
            cpassword => 'a',
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
    
    File::Path::rmtree('t/db');
    
    unless(main::is_deeply( [ $D->live_objects->live_objects ], [ ], "no live objects" )) {
        main::diag(" Live objects: " . join(", ", $D->live_objects->live_objects));
    }
    main::done_testing();
}
1;
