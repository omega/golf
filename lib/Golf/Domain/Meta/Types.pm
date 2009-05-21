package Golf::Domain::Meta::Types;

use MooseX::Types
    -declare => [qw/
        Hole HoleArray
        RoundHoleScore RoundHoleScoreArray
        Player PlayerList
    /
    ]
;

use Golf::Domain::Hole;

use MooseX::Types::Moose qw(ArrayRef Int);
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

class_type RoundHoleScore, { class => 'Golf::Domain::RoundHoleScore' };

#coerce RoundHoleScore,
#    from HashRef
subtype RoundHoleScoreArray,
    as ArrayRef[RoundHoleScore]
;

