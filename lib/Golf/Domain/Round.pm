use MooseX::Declare;

class Golf::Domain::Round 
with Golf::Domain::Meta::Extractable
with Golf::Domain::Meta::Updateable
with Golf::Domain::Meta::ID {

    use Golf::Domain::Meta::Types qw/
        PlayerRoundList Date Course Hole
        ScoreList
    /;
    use Golf::Domain::Score;
    
    use Carp qw/croak/;
    
    use Digest::SHA1 qw/sha1_hex/;
    
    has 'id'    => (
        traits  => [qw/Extract/],
        is => 'ro', 
        isa => 'Str', 
        lazy_build => 1,
    );
    
    method _build_id {
        sha1_hex($self->date . "-" 
            . $self->course->name . "-" . rand(10000)
        );
    };
    
    has 'date' => (
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
        is => 'rw',
        coerce => 1,
        isa => PlayerRoundList,
        provides => {
            'grep' => 'grep_players',
            'get'  => '_get_player',
        }
    );
    method get_player(Str $id) {
        my ($p) = $self->grep_players(sub { 
            $_[0]->player->id eq $id 
        });
        return $p;
    }
    method has_player(Str $id) {
        !!$self->get_player($id);
    }
    method get_next_hole() {
        
        # Figure out how many holes we have played, add one and
        # get that hole from the course.
        $self->course->get_hole($self->_get_player(0)->count_scores + 1);
        
    }
    method add_hole_scores(HashRef $scores) {
        
        # Figure out next hole, 
        my $hole = $self->get_next_hole;
        
        $self->set_hole_scores($hole, $scores);
    }
    
    method set_hole_scores(Hole $hole, HashRef $scores) {
        foreach my $k (keys %$scores) {
            my $s = $scores->{$k};
            my ($throws, $dropped) = ref($s) ? @$s : ($s, 0);
            my $p = $self->get_player($k);
            croak("no player $k") unless $p;
            
            # Now we set the score
            my $score = Golf::Domain::Score->new(
                hole => $hole,
                score => $throws,
                player => $p->player,
                dropped => $dropped,
            );
            $p->add_score($score);
        }
    }
}