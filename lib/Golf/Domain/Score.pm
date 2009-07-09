use MooseX::Declare;

class Golf::Domain::Score {
    
    has 'player' => (is => 'ro', isa => 'Golf::Domain::Player', weak_ref => 1);
    has 'score' => (is => 'rw', isa => 'Int');
    has 'dropped' => (is => 'rw', isa => 'Bool');
    has 'hole' => (is => 'ro', isa => 'Golf::Domain::Hole', weak_ref => 1);
};