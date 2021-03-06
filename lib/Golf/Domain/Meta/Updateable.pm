use MooseX::Declare;

role Golf::Domain::Meta::Updateable {
    use Data::Dump qw/dump/;
    method update(HashRef $attrs, Golf::Domain $domain) {
        # walk $attrs, look for coresponding attributes
        # on $self and update them
        
        foreach my $k (%$attrs) {
            if ($self->can($k)) {
                # We have a matching attr!
                my $attr = $self->meta->find_attribute_by_name($k);
                if (my $m = $self->can("update_$k")) {
                    $self->$m($attrs, $domain);
                } elsif ($attr->has_write_method and $attrs->{$k}) {
                    my $m = $attr->get_write_method;
                    $self->$k($attrs->{$k});
                }
            }
        }
    }
}
