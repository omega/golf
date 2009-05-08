package Golf::Model::Kioku;
use Moose;
use Golf::Domain;

BEGIN { 
    extends qw(Catalyst::Model::KiokuDB) 
}

__PACKAGE__->config(
    model_class => 'Golf::Domain',
);

1;
