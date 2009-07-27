use MooseX::Declare;

class Golf::Domain::Player 
with KiokuX::User 
with Golf::Domain::Meta::Extractable
with Golf::Domain::Meta::Updateable {
    use KiokuX::User::Util qw/crypt_password/;
    use Carp qw/croak/;
    use Golf::Domain::Round;
    use KiokuDB::Util qw/set/;
    
    use Golf::Domain::Meta::Types qw/
        RoundSet
    /;
    
    method create(HashRef $args) {
        
        # check password and cpassword
        croak("need id column") unless $args->{id};
        if ($args->{password} and $args->{cpassword}
            and $args->{password} eq $args->{cpassword}
        ) {
            delete $args->{cpassword};
            $args->{password} = crypt_password($args->{password});
        } else {
            croak("Password and cpassword does not match, or one is missing");
        }
        
        __PACKAGE__->new($args);
    }
    
    
    has 'name' => (
        traits => [qw/Extract/],
        is => 'rw', 
        isa => 'Str', 
        required => 0
    );
    has 'description' => (
        traits => [qw/Extract/],
        is => 'rw',
        isa => 'Str',
        required => 0,
    );
    
    has 'rounds' => (
        isa => RoundSet,
        is => 'rw',
        default => sub { set() },
        handles => {
            'has_round' => 'member',
            'add_round' => 'insert',
            'remove_round' => 'remove',
        }
    );
=pod
    method remove_round(Golf::Domain::Round $round) {
        my ($r) = grep {
            $_->id eq $round->id
        } $self->rounds->members;
        my $c = $self->rounds->remove($r);
        
        warn "   - removed $c rounds";
        
        warn "     rounds: " . join(", ",  map { $_->id } $self->rounds->members );
        
    }
=cut
    method courses() {
        my $courses = {};
        
        $self->_map_rounds( sub {
            $courses->{ $_->course->name } = $_->course;
        });
        
        return values(%$courses);
    }
    method rounds_by_course_name(Str $name) {
        my @rounds = grep {
            $_->course->name eq $name
        } $self->rounds->members;
        \@rounds;
    }
}