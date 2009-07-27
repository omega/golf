
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
    
    method create(Str $class, HashRef $args) {
        my $full_class = "Golf::Domain::$class";
        Class::MOP::load_class($full_class) 
            unless Class::MOP::is_class_loaded($full_class);
        my $obj;
        if (my $m = $full_class->can('create') || $self->can('create_' . lc($class))) {
            # We call a specialized method
            $obj = $m->($self, $args);
        } else {
            $obj = $full_class->new($args);
        }
        $self->store($obj);
        return $obj;
    }
    method update(Object $obj, HashRef $args) {
        if ($obj->does('Golf::Domain::Meta::Updateable')) 
        {
            $obj->update($args, $self);
            $self->directory->store($obj);
            
        } else {
            croak("Cannot update $obj, doesn't do Updateable");
        }
    }
    method remove(Object $obj) {
        $obj->remove($self) if ($obj->can('remove'));
        $self->directory->delete($obj);
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
