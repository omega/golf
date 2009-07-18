use MooseX::Declare;

class Golf::Domain::Round 
with Golf::Domain::Meta::Extractable
with Golf::Domain::Meta::ID
with Golf::Domain::Meta::Updateable {

    use Golf::Domain::Meta::Types qw/
        PlayerRoundSet Date Course Hole
        
    /;
    
    use KiokuDB::Util qw/set/;
    
    use Golf::Domain::Score;
    
    use Carp qw/croak/;
    
    use Digest::SHA1 qw/sha1_hex/;

    method create(HashRef $args) {
        unless (ref($args->{course})) {
            $args->{course} = Golf::Domain::Search->coerce_course($args->{course});
        }
        
        unless (ref($args->{players} eq 'ARRAY')) {
            my $ps = $args->{players};
            $ps = [$ps] unless ref($ps);
            map {
                $_ = Golf::Domain::PlayerRound->new(
                    player => Golf::Domain::Search->coerce_player($_)
                );
            } @$ps;
            
            $args->{players} = $ps;
        }
        my $round = __PACKAGE__->new($args);
        
        # walk the players and add this round to their rounds
 
        map {
            $_->player->add_round($round);
        } $round->players->members;

        $round->course->add_round($round);
        $round;
    }
    method update_players(HashRef $args) {
        # should take care of removing players that are no longer there
        # and adding new players etc.
        $self->course->add_round($self);
        
        # figure out what players we have in $args
        my $new_players = $args->{players};
        
        my @rounds = $self->players->members;
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
        map {
            $_->player->add_round($self);
        } @rounds;
        $self->players(\@rounds);
    }
    method remove {
        # Walk the players and REMOVE this round from their rounds
        map {
            $_->player->remove_round($self);
        } $self->players->members;
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
        isa => PlayerRoundSet,
        coerce => 1,
        is => 'rw',
    );
    
    method get_player(Str $id) {
        my ($p) = grep { 
            $_->player->id eq $id 
        } $self->players->members;
        return $p;
    }
    method has_player(Str $id) {
        !!$self->get_player($id);
    }
    
    method holes_played() {
        my $max_played = 0;
        
        map {
            $max_played = $_->count_scores if $_->count_scores > $max_played
        } $self->players->members;
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
            if (my $score = $p->get_score($hole)) {
                $score->score($throws);
                $score->dropped($dropped);
            } else {
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
}