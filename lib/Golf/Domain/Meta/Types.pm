package Golf::Domain::Meta::Types;

use MooseX::Types
    -declare => [qw/
        Course
        Hole HoleArray
        RoundHoleScore RoundHoleScoreArray
        Player PlayerList
        Date
    /
    ]
;

use Golf::Domain::Hole;
use Golf::Domain::Search;

use DateTime::Format::ISO8601;

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

class_type Course, { class => 'Golf::Domain::Course' };

coerce Course, 
    from Str,
        via {
            Golf::Domain::Search->coerce_course($_)
        }
;

class_type Date, { class => 'DateTime' };

coerce Date,
    from Str,
        via {
            DateTime::Format::ISO8601->parse_datetime($_);
        }
;

=pod

class_type RoundHoleScore, { class => 'Golf::Domain::RoundHoleScore' };

#coerce RoundHoleScore,
#    from HashRef
subtype RoundHoleScoreArray,
    as ArrayRef[RoundHoleScore]
;

=cut


1;

