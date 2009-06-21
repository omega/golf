package Golf::Domain::Meta::Types;

use MooseX::Types
    -declare => [qw/
        Course
        Hole HoleArray
        RoundHoleScore RoundHoleScoreArray
        Player PlayerList
        PlayerRound PlayerRoundList
        Date
        Score ScoreList
    /
    ]
;

use Golf::Domain::Hole;
use Golf::Domain::Search;
use Golf::Domain::PlayerRound;

use DateTime::Format::ISO8601;
use DateTime::Format::Strptime;

use MooseX::Types::Moose qw(ArrayRef Int Str);
use Moose::Util::TypeConstraints;

class_type Hole, { class => 'Golf::Domain::Hole' };
subtype HoleArray,
    as ArrayRef[Hole]
;

coerce HoleArray,
    from ArrayRef[Int],
        via { my @holes = map { 
            Golf::Domain::Hole->new( par => $_ ) 
        } @$_; \@holes },
    from Int,
        via {
            [Golf::Domain::Hole->new( par => $_ ) ]
        }
    
;


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

subtype PlayerRoundList,
    as ArrayRef[PlayerRound]
;

coerce PlayerRoundList,
    from Player,
        via {
            [Golf::Domain::PlayerRound->new(player => $_)]
        },
    from ArrayRef[Player],
        via {
            my @plr = map {
                Golf::Domain::PlayerRound->new(
                    player => $_
                );
            } @$_;
            \@plr;
        },
    from ArrayRef[Str],
        via {
            my @players = map { 
                Golf::Domain::PlayerRound->new(
                    player => Golf::Domain::Search->coerce_player($_)
                );
            } @$_;
            \@players;
        },
    from Str,
        via {
            [ Golf::Domain::PlayerRound->new(
                player => Golf::Domain::Search->coerce_player($_)
            ) ]
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

subtype ScoreList,
    as ArrayRef[Score]
;

1;

