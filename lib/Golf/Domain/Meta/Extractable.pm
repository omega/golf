use MooseX::Declare;

role Golf::Domain::Meta::Extractable {
    use Data::Dump qw/dump/;
    use Golf::Domain::Meta::Attribute::Trait::Extract;
    method extract(:$entry) {
        my $attr = {
              %{ $self->extract_attributes },
              __CLASS__ => ref $self
        };
        
        $attr;
    }
    
    method extract_attributes() {
        return {
            map {
                my $val = $_->get_value($self);
                if (ref($val) and $val->does('Golf::Domain::Meta::Extractable')) {
                    # XXX: this needs to be generalized, specify ->name somehow
                    $val = $val->name
                }
                $_->name => (defined($val) ? $val : undef);
            } grep {
                $_->does('Golf::Domain::Meta::Attribute::Trait::Extract')
            } $self->meta->get_all_attributes
            
        };
    }
    
}
