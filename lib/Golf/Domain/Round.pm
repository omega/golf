use MooseX::Declare;

class Golf::Domain::Round with Golf::Domain::Meta::Extractable {

    use Golf::Domain::Meta::Types qw/PlayerList/;
    
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
    
    has 'course' => (
        traits  => [qw/Extract/],
        is      => 'rw',
        isa     => 'Golf::Domain::Course',
        required => 1,
    );
    
    has 'players' => (
        metaclass => 'Collection::Array',
        is => 'ro',
        isa => PlayerList,
        
    )
}