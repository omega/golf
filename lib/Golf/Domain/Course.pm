use MooseX::Declare;

class Golf::Domain::Course {
    has 'name' => (
        is      => 'rw',
    );
}