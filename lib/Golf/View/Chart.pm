package Golf::View::Chart;


use strict;
use base 'Catalyst::View';

use Chart::Clicker;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::DataSet;

use Chart::Clicker::Context;
use Chart::Clicker::Axis::DateTime;

use Chart::Clicker::Renderer::Bubble;

use Geometry::Primitive::Circle;
use Graphics::Primitive::Brush;

use Graphics::Color::RGB;

sub process {
    my ( $self, $c ) = @_;
    
    my $D = $c->stash->{data};
    $D->{options} ||= {};
    $D->{serie_type} ||= 'Series';
    $c->res->content_type('image/svg+xml');
    
    my $cc = Chart::Clicker->new( 
        format => 'svg',
        %{ $D->{options} }
    );
    my $context = $cc->get_context('default'); #Chart::Clicker::Context->new( name => 'default' );


    if (my $marker = $D->{marker}) {
        my $mark = Chart::Clicker::Data::Marker->new(
            color   => Graphics::Color::RGB->new,
            brush  => Graphics::Primitive::Brush->new,
            %{ $marker },
         );
        
        $context->add_marker($mark);
    }
    if (my $t = $D->{ticks}) {
        $context->domain_axis->tick_values($t->{values});
        $context->domain_axis->tick_labels($t->{labels});
        $context->domain_axis->tick_label_angle(1.5);
        
        $cc->legend->visible(0);
    }
    $context->range_axis->format('%d');
    $context->range_axis->fudge_amount(0.1);
    $context->domain_axis->fudge_amount(0.1);

    my @series;
    my $type = 'Chart::Clicker::Data::' . $D->{serie_type};
    Class::MOP::load_class($type) unless Class::MOP::is_class_loaded($type);
    foreach my $s ( @{ $c->stash->{data}->{series} } ) {
        push(@series, $type->new(%{ $s }));
    }
    my $ds = Chart::Clicker::Data::DataSet->new( series => \@series );
    $context->renderer(Chart::Clicker::Renderer::Bubble->new);
    $cc->add_to_datasets($ds);
    
    $cc->draw;
    
    $c->res->body($cc->data);
}



1;