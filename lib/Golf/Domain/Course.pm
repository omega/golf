use MooseX::Declare;

class Golf::Domain::Course 
with Golf::Domain::Meta::Extractable 
with Golf::Domain::Meta::Updateable 
{
    use MooseX::AttributeHelpers;
    use Golf::Domain::Round;
    
    use Golf::Domain::Meta::Types qw/HoleArray RoundList/;
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
        # XXX: Should probably grep idx == $idx instead
        return $self->_get_hole($idx - 1);
    }
    method update_rounds(HashRef $args) {
        $self->{rounds} = [] unless $self->rounds;
    }
    has 'rounds' => (
        metaclass => 'Collection::Array',
        is => 'rw',
        coerce => 1,
        isa => RoundList,
        provides => {
            'push' => '_add_round',
            'grep' => '_grep_rounds',
            'map'  => '_map_rounds',
            'count' => 'number_of_rounds',
        },
        default => sub { [] },
    );
    
    method has_round(Golf::Domain::Round $round) {
        return unless ref($self->rounds);
        return $self->_grep_rounds(sub { $_->id eq $round->id })
    }
    method add_round(Golf::Domain::Round $round) {
        $self->{rounds} = [] unless $self->rounds;
        $self->_add_round($round) 
            unless $self->has_round($round);
    }
    method remove_round(Golf::Domain::Round $round) {
        $self->rounds( $self->_grep_rounds( sub {
            $_->id ne $round->id
        } ) ) if $self->has_round($round);
    }

    method par() {
        my $s = 0;
        $self->_map( sub { $s = $s + $_->par  } );
        
        return $s;
    }
}