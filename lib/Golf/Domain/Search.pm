use MooseX::Declare;

class Golf::Domain::Search {
    
    use Golf::Domain;
    use Carp qw/croak/;
    
    # XXX: Should perhaps be some sort of accessor?
#    has 'domain' => (is => 'ro', isa => 'Golf::Domain', lazy_build => 1);
    method domain($class:) {
        
        # XXX: Get config I presume?
        
        Golf::Domain->new(dsn => $ENV{GOLF_DSN} || 'bdb-gin:dir=db/');
    };
    
    
    method coerce_player($class: Str $id) {
        my $d = $class->domain;
        my $s = $d->new_scope;
        $d->lookup('user:' . $id);
    }
    
    method coerce_course($class: Str $name) {
        my $d = $class->domain;
        my $s = $d->new_scope;
        $d->find(Course => { name => $name });
        
    }
};