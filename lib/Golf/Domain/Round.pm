use MooseX::Declare;

class Golf::Domain::Round with Golf::Domain::Meta::Extractable {

    use Golf::Domain::Meta::Types qw/PlayerList Date Course/;
    use Digest::SHA1 qw/sha1_hex/;
    
=pod

    has '_scores' => (
        is      => 'ro',
        isa     => 'KiokuDB::Set',
        required => 0,
        default => sub { set() },
        handles => {
            'scores' => 'members',
        }
    );

=cut

    has 'id'    => (is => 'ro', isa => 'Str', lazy_build => 1);
    
    method _build_id {
        sha1_hex($self->date . "-" 
            . $self->course->name . "-" . rand(10000)
        );
    };
    
    has 'date' => (
        traits => [qw/Extract/],
        is => 'rw', 
        isa => Date,
        coerce => 1,
    );
    
    has 'course' => (
        traits  => [qw/Extract/],
        is      => 'rw',
        isa     => Course,
        required => 1,
        coerce => 1,
    );
    
    has 'players' => (
        metaclass => 'Collection::Array',
        is => 'ro',
        coerce => 1,
        isa => PlayerList,
        
    )
}