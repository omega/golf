use MooseX::Declare;

class Golf::Domain::Course 
with Golf::Domain::Meta::Extractable 
with Golf::Domain::Meta::Updateable 
{
    use MooseX::AttributeHelpers;
    use Golf::Domain::Round;
    use KiokuDB::Util qw/set/;
    
    use Golf::Domain::Meta::Types qw/HoleSet RoundSet/;
    has 'name' => (
        is      => 'rw',
        traits => [qw/Extract/],
        required => 1,
    );

    has 'holes' => (
#        does => 'KiokuDB::Set',
        isa => HoleSet,
        is => 'rw',
        coerce => 1,
        default => sub { set() },
        handles => {
            'size' => 'size',
        }
    );
    
    method get_hole(Int $idx) {
        # XXX: Should probably grep idx == $idx instead
        
        my ($hole) = grep { $_->idx == $idx } $self->holes->members;
        return $hole;
    }
    has 'rounds' => (
        isa => RoundSet,
        is => 'rw',
        default => sub { set() },
        handles => {
            'has_round' => 'has',
            'add_round' => 'insert',
            'remove_round' => 'remove',
            
        }
    );

    method par() {
        my $s = 0;
        map { 
            $s = $s + $_->par;
        } $self->holes->members;
        return $s;
    }
}