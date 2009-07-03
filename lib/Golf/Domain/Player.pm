use MooseX::Declare;

class Golf::Domain::Player 
with KiokuX::User 
with Golf::Domain::Meta::Extractable
with Golf::Domain::Meta::Updateable {
    use KiokuX::User::Util qw/crypt_password/;
    use Carp qw/croak/;
    use Golf::Domain::Round;
    use Golf::Domain::Meta::Types qw/
        RoundList Round
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
        metaclass => 'Collection::Array',
        is => 'rw',
        coerce => 1,
        isa => RoundList,
        provides => {
            'push' => '_add_round',
            'grep' => '_grep_rounds',
        },
        default => sub { [] },
    );
    method has_round(Golf::Domain::Round $round) {
        return unless ref($self->rounds);
        return $self->_grep_rounds(sub { $_->id eq $round->id })
    }
    method add_round(Golf::Domain::Round $round) {
        $self->_add_round($round) 
            unless $self->has_round($round);
    }
    method remove_round(Golf::Domain::Round $round) {
        $self->rounds( $self->_grep_rounds( sub {
            $_->id ne $round->id
        } ) ) if $self->has_round($round);
    }
}