use MooseX::Declare;

class Golf::Domain::Hole {
    has 'par' => (
        traits => [qw/Extract/],
        is => 'rw',
        isa => 'Int',
    );
}