use MooseX::Declare;

class Golf::Domain::PlayerRound {
    use MooseX::AttributeHelpers;
    
    use Golf::Domain::Meta::Types qw/
        ScoreList
    /;
    
    has 'player' => (isa => 'Golf::Domain::Player', is => 'ro', coerce => 1);
    
    has 'scores' => (
        metaclass => 'Collection::Array',
        # XXX: No idea why this fails :(
#        isa => ScoreList, 
        isa => 'ArrayRef',
        is => 'rw',
        default => sub { [] },
        coerce => 1,
        auto_deref => 1,
        provides => {
            'push' => 'add_score',
            'get' => '_get_score',
            'set' => 'set_score',
            'count' => 'count_scores',
            'map' => '_map_scores',
            'grep' => '_grep_scores',
        },
    );
    method get_score(Golf::Domain::Hole $hole) {
        return $self->_get_score($hole->idx - 1);
    }
    method total_score() {
        my $s;
        $self->_map_scores(sub {
            $s += $_->score
        });
        return $s;
    }
}