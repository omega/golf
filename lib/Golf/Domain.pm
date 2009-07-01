
use MooseX::Declare;


class Golf::Domain extends KiokuX::Model {

    use MooseX::ClassAttribute;
    
    use KiokuX::User::Util qw(crypt_password);
    use Carp qw/croak carp/;
    use Search::GIN::Query::Manual;
    use Search::GIN::Extract::Callback;
    
    use Data::Dump qw/dump/;
    class_has '_singleton' => (
        is => 'rw',
        isa => 'HashRef',
        default => sub { { } },
    );
    
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
        
        Class::MOP::load_class("Golf::Domain::Player") 
            unless Class::MOP::is_class_loaded("Golf::Domain::Player");
        
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
            Class::MOP::load_class($class) 
                unless Class::MOP::is_class_loaded($class);
            my $o = $class->new($args);
            $self->insert($o);
            return $o;
        }

    }
    method update(Object $obj, HashRef $args) {
        if ($obj->does('Golf::Domain::Meta::Updateable')) {
            $obj->update($args);
            $self->directory->store($obj);
        } else {
            croak("Cannot update $obj, doesn't do Updateable");
        }
    }
    method find(Str $class, HashRef $query) {
        my $stream = $self->search({
            # XXX: this results in OR, which is bad            TYPE => $class,
            %$query,
        });
        my @all = $stream->all;
        if (scalar(@all) > 1) {
            carp("found " . scalar(@all) . " objects with find, something wrong?\n" .
                join(", ", map { $_->name } @all)
            );
        }
        return $all[0];
    }
    
    around search(HashRef $args) {
        my $q = Search::GIN::Query::Manual->new(
            values => $args,
            method => 'all',
        );
        return $orig->($self, $q);
    }
        
    around _build_directory() {

        if ($self->dsn eq 'copy') {
            if (my ($k) = keys(%{ $self->_singleton })) {
                return $self->_singleton->{$k};
            }
        }
        return $self->_singleton->{$self->dsn} if $self->_singleton->{$self->dsn};

        my $dir = $orig->($self);
        $self->_singleton->{$self->dsn} = $dir;
        
        return $dir;
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
