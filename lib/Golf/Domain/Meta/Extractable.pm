use MooseX::Declare;

role Golf::Domain::Meta::Extractable {
    use Data::Dump qw/dump/;
    use Carp qw/carp/;
    use Golf::Domain::Meta::Attribute::Trait::Extract;
    method extract(:$entry) {
        my $cls = ref $self;
        $cls =~ s/^Golf::Domain:://;
        my $attr = {
              %{ $self->extract_attributes },
              TYPE => $cls
        };
        $attr;
    }
    
    method extract_attributes() {
        return {
            map {
                my $val = $_->get_value($self);
                if (ref($val) and $val->can('does')
                    and $val->does('Golf::Domain::Meta::Extractable')) {
                    # XXX: this needs to be generalized, specify ->name somehow
                    $val = $val->name
                }
                (defined $val ? ($_->name => $val) : ());
            } grep {
                $_->does('Golf::Domain::Meta::Attribute::Trait::Extract')
            } $self->meta->get_all_attributes
            
        };
    }
    
}
