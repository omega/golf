use MooseX::Declare;

class Golf::Domain::PlayerRound {
    use MooseX::AttributeHelpers;
    use Golf::Domain::Hole;
    use Golf::Domain::Score;
    use KiokuDB::Util qw/set/;
    
    use Golf::Domain::Meta::Types qw/
        ScoreSet
    /;
    
    has 'player' => (
        isa => 'Golf::Domain::Player', 
        is => 'ro', 
        weak_ref => 1,
    );
    
    has 'scores' => (
        does => 'KiokuDB::Set',
#        isa => ScoreSet,
        is => 'rw',
        default => sub { set() },
        handles => {
            'count_scores' => 'size',
            'add_score' => 'insert',
        }
    );
    method get_score(Golf::Domain::Hole $hole) {
        my ($score) = grep {
            $_->hole == $hole;
        } $self->scores->members;
        return $score;
    }
    method total_score() {
        my $s = 0;
        map {
            $s += $_->score
        } $self->scores->members;
        return $s;
    }

}