use MooseX::Declare;

class Golf::Domain::Course 
with Golf::Domain::Meta::Extractable 
with Golf::Domain::Meta::Updateable 
{
    use MooseX::AttributeHelpers;
    use Golf::Domain::Meta::Types qw/HoleArray/;
    has 'name' => (
        is      => 'rw',
        traits => [qw/Extract/],
        required => 1,
    );
    
    has 'holes' => (
        metaclass => 'Collection::Array',
        is => 'rw',
        isa => HoleArray,
        default => sub { [] },
        coerce => 1,
        auto_deref => 1,
        provides => {
            'push' => 'add_hole',
            'get' => '_get_hole',
            'count' => 'size',
            'map' => '_map',
            'clear' => '_clear_holes',
        },
        
        
    );
    method get_hole(Int $idx) {
        return $self->_get_hole($idx - 1);
    }
    method par() {
        my $s = 0;
        $self->_map( sub { $s = $s + $_->par  } );
        
        return $s;
    }
}