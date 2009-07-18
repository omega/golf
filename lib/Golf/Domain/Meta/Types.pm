package Golf::Domain::Meta::Types;

use MooseX::Types
    -declare => [qw/
        Course
        Hole HoleSet
        Player PlayerList
        PlayerRound PlayerRoundSet
        Round RoundSet
        Date
        Score ScoreSet
    /
    ]
;

use KiokuDB::Util qw/set/;
use KiokuDB::Set;

use Golf::Domain::Hole;
use Golf::Domain::Search;
use Golf::Domain::PlayerRound;

use DateTime::Format::ISO8601;
use DateTime::Format::Strptime;

use MooseX::Types::Moose qw(ArrayRef Int Str Object);
use Moose::Util::TypeConstraints;

subtype HoleSet, as 'KiokuDB::Set';

coerce HoleSet,
    from ArrayRef[Int],
        via {
            my $idx = 0;
            my @holes = map {
                $idx++;
                Golf::Domain::Hole->new( par => $_, idx => $idx ) 
            } @$_; 
            set(@holes);
        },
    from Int,
        via {
            set(Golf::Domain::Hole->new( par => $_, idx => 1 ));
        }
;

class_type Hole, { class => 'Golf::Domain::Hole' };

class_type Round, { class => 'Golf::Domain::Round' };

subtype RoundSet, as 'KiokuDB::Set';

class_type Player, { class => 'Golf::Domain::Player' };
coerce Player ,
    from Str,
        via {
            Golf::Domain::Search->coerce_player($_);
        }
;

subtype PlayerList,
    as ArrayRef[Player]
;

coerce PlayerList,
    from Player,
        via {
            [$_]
        },
    from ArrayRef[Str],
        via {
            my @players = map { 
                Golf::Domain::Search->coerce_player($_)
            } @$_;
            \@players;
        },
    from Str,
        via {
            [ Golf::Domain::Search->coerce_player($_) ]
        }
        
;


class_type PlayerRound, { class => 'Golf::Domain::PlayerRound' };


subtype PlayerRoundSet, as 'KiokuDB::Set';

coerce PlayerRoundSet,
    from Player,
        via {
            set(Golf::Domain::PlayerRound->new(player => $_));
        },
    from ArrayRef[Player],
        via {
            set(map {
                Golf::Domain::PlayerRound->new(
                    player => $_
                );
            } @$_);
        },
    from ArrayRef[Str],
        via {
            set(map { 
                Golf::Domain::PlayerRound->new(
                    player => Golf::Domain::Search->coerce_player($_)
                );
            } @$_);
        },
    from ArrayRef[PlayerRound],
        via {
            set(@$_);
        },
    from Str,
        via {
            set(Golf::Domain::PlayerRound->new(
                player => Golf::Domain::Search->coerce_player($_)
            ));
        }
        
;

class_type Course, { class => 'Golf::Domain::Course' };

coerce Course, 
    from Str,
        via {
            Golf::Domain::Search->coerce_course($_);
        }
;

class_type Date, { class => 'DateTime' };

coerce Date,
    from Str,
        via {
            my $dt = DateTime::Format::ISO8601->parse_datetime($_);
            $dt->set_formatter(DateTime::Format::Strptime->new(pattern => "%F"));
            $dt;
        }
;


class_type Score, { class => 'Golf::Domain::Score' };

subtype ScoreSet, as 'KiokuDB::Set';

1;

