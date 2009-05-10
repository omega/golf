use MooseX::Declare;

class Golf::Domain::Course with Golf::Domain::Meta::Extractable {
    use MooseX::AttributeHelpers;
    use Golf::Domain::Meta::Types qw/HoleArray/;
    has 'name' => (
        is      => 'rw',
        traits => [qw/Extract/],
    );
    
    has 'holes' => (
        metaclass => 'Collection::Array',
        is => 'ro',
        isa => HoleArray,
        default => sub { [] },
        coerce => 1,
        auto_deref => 1,
        provides => {
            'push' => 'add_hole',
            'count' => 'size',
            'map' => '_map',
        },
        
        
    );
    
    method par() {
        my $s = 0;
        $self->_map( sub { $s = $s + $_->par  } );
        
        return $s;
    }
}