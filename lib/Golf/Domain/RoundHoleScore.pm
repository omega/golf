use MooseX::Declare;

class Golf::Domain::RoundHoleScore with Golf::Domain::Meta::Extractable {
    has 'score' => (
        is => 'rw',
        isa => 'Int',
    );
}