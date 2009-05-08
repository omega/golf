package Golf::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    WRAPPER => 'inc/wrap.tt',
);

=head1 NAME

Golf::View::TT - TT View for Golf

=head1 DESCRIPTION

TT View for Golf. 

=head1 AUTHOR

=head1 SEE ALSO

L<Golf>

Andreas Marienborg

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
