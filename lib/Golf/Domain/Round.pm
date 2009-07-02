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

    method create(HashRef $args) {
        my $round = __PACKAGE__->new($args);
        
        # walk the players and add this round to their rounds
        $round->_map_players(sub {
            $_->player->add_round($round);
        });

        $round;
    }
    method update_players(HashRef $args) {
        use Data::Dump qw/dump/;
        # should take care of removing players that are no longer there
        # and adding new players etc.

        # figure out what players we have in $args
        my $new_players = $args->{players};
        
        my @rounds = @{$self->players};
        foreach my $pr (@rounds) {
            unless (grep { $pr->player->id eq $_ } @$new_players) {
                $pr->player->remove_round($self);
                $pr = ();
            }
        }
        @rounds = grep { ref $_ } @rounds;
        map { 
            my $p = Golf::Domain::Search->coerce_player($_);
            
            unless ($self->has_player($p->id)) {
                $p->add_round($self);
                push(@rounds, Golf::Domain::PlayerRound->new( player => $p ));
            }
        } @$new_players;
        
        $self->players(\@rounds);
    }
    method remove {
        # Walk the players and REMOVE this round from their rounds
        $self->_map_players(sub {
            $_->player->remove_round($self);
        });
    }
    
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
            'map'  => '_map_players',
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
    
    method holes_played() {
        my $max_played = 0;
        
        $self->_map_players(sub {
            $max_played = $_->count_scores if $_->count_scores > $max_played
        });
        return $max_played;
    }
    method get_next_hole() {
        $self->course->get_hole($self->holes_played + 1);
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