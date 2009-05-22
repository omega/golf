
use MooseX::Declare;


class Golf::Domain extends KiokuX::Model {

    # XXX: Fix this somehow, its annoying!
    use Golf::Domain::Player;
    use Golf::Domain::Course;
    use Golf::Domain::Round;
    
    use KiokuX::User::Util qw(crypt_password);
    use Carp qw/croak/;
    use Search::GIN::Query::Manual;
    use Search::GIN::Extract::Callback;
    
    use Data::Dump qw/dump/;
    
    # XXX: Should this really be in the Player-class?
    method create_player(HashRef $args) {

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
        
        my $p = Golf::Domain::Player->new($args);
        $self->insert($p);
        
        return $p;
    }
    method create(Str $class, HashRef $args) {

        if (my $m = $self->can('create_' . lc($class))) {
            # We call a specialized method
            return $m->($self, $args);
        } else {
            $class = "Golf::Domain::$class";
            warn dump($class => $args);
            my $o = $class->new($args);
            $self->insert($o);
            return $o;
        }

    }
    method update(Object $obj, HashRef $args) {
        if ($obj->does('Golf::Domain::Meta::Updateable')) {
            $obj->update($args);
            warn "Calling update on the directory";
            $self->directory->store($obj);
            warn "returning from update on directory";
        } else {
            croak("Cannot update $obj, doesn't do Updateable");
        }
    }
    method find(Str $class, HashRef $query) {
        my $stream = $self->search({
            %$query,
            TYPE => $class,
        });
        my @all = $stream->all;
        return $all[0];
    }
    
    around search(HashRef $args) {
        my $q = Search::GIN::Query::Manual->new(
            values => $args
        );
        return $orig->($self, $q);
    }
    
    
    around _build__connect_args() {
        
        my $args = $orig->($self);
        # mangle args
        my $extract = Search::GIN::Extract::Callback->new(
            extract => sub {
                my ($obj, $extractor, @args) = @_;
                
                if ($obj->does('Golf::Domain::Meta::Extractable')) {
                    return $obj->extract();
                }
            }
        );
        
        push(@$args, extract => $extract);
        $args;
    }
};


1;
