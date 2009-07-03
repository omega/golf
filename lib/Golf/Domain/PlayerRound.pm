use MooseX::Declare;

class Golf::Domain::PlayerRound {
    use MooseX::AttributeHelpers;
    use Golf::Domain::Hole;
    use Golf::Domain::Score;
    
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
            'push' => '_add_score',
            'get' => '_get_score',
            'set' => '_set_score',
            'count' => 'count_scores',
            'map' => '_map_scores',
            'grep' => '_grep_scores',
        },
    );
    method set_score(Golf::Domain::Hole $hole, Golf::Domain::Score $score) {
        $self->_set_score($hole->idx - 1, $score);
    }
    method get_score(Golf::Domain::Hole $hole) {
        return $self->_get_score($hole->idx - 1);
    }
    method total_score() {
        my $s = 0;
        $self->_map_scores(sub {
            $s += $_->score
        });
        return $s;
    }
}