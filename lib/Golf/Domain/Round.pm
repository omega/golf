use MooseX::Declare;

class Golf::Domain::Round 
with Golf::Domain::Meta::Extractable
with Golf::Domain::Meta::Updateable
with Golf::Domain::Meta::ID {

    use Golf::Domain::Meta::Types qw/PlayerList Date Course/;
    use Digest::SHA1 qw/sha1_hex/;
    
=pod

    has '_scores' => (
        is      => 'ro',
        isa     => 'KiokuDB::Set',
        required => 0,
        default => sub { set() },
        handles => {
            'scores' => 'members',
        }
    );

=cut

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
        isa => PlayerList,
        provides => {
            'grep' => 'grep_players',
        }
    );
    method get_player(Str $id) {
        $self->grep_players(sub { 
            $_[0]->id eq $id 
        });
    }
    method has_player(Str $id) {
        !!$self->get_player($id);
    }
    
    method add_hole_scores(HashRef $scores) {
        
        # Figure out next hole, 
        foreach my $k (keys %$scores) {
            
        }
    }
    
    method set_hole_scores(HashRef $scores) {
        
    }
}