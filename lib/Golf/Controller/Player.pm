package Golf::Controller::Player;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Golf::Domain::Player;

=head1 NAME

Golf::Controller::Player - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

}

sub create : Local {
    my ( $self, $c ) = @_;
    
    # show a form. Can't we somehow introspect this out of the class??
    
    $c->stash( attrs => [Golf::Domain::Player->meta->get_all_attributes] );
}

=head1 AUTHOR

Andreas Marienborg

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
