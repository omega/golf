use MooseX::Declare;

class Golf::Domain::Round with Golf::Domain::Meta::Extractable {
    use KiokuDB::Util qw(set);
    
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
        is      => 'rw',
        isa     => 'Golf::Domain::Course',
        required => 1,
    );
}