package Golf::View::Chart;


use strict;
use base 'Catalyst::View';

use Chart::Clicker;
use Chart::Clicker::Data::Series;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::DataSet;

use Chart::Clicker::Context;
use Chart::Clicker::Axis::DateTime;


use Geometry::Primitive::Circle;
use Graphics::Primitive::Brush;

use Graphics::Color::RGB;

sub process {
    my ( $self, $c ) = @_;
    $c->res->content_type('image/png');
    
    my $cc = Chart::Clicker->new( format => 'png' );
    my $context = $cc->get_context('default'); #Chart::Clicker::Context->new( name => 'default' );

    $context->domain_axis(Chart::Clicker::Axis::DateTime->new(
        orientation => 'horizontal',
        position    => 'bottom',
        format      => '%d. %b',
        fudge_amount => 0.1,
    ));


    if (my $marker = $c->stash->{data}->{marker}) {
        my $mark = Chart::Clicker::Data::Marker->new(
            color   => Graphics::Color::RGB->new,
            brush  => Graphics::Primitive::Brush->new,
            %{ $marker },
         );
        
        $context->add_marker($mark);
    }
    
    $context->renderer->shape(Geometry::Primitive::Circle->new({ radius => 5, }));
    $context->renderer->shape_brush(Graphics::Primitive::Brush->new({ 
        width => 2, 
        color => Graphics::Color::RGB->new(red => 0.95, green => 0.94, blue => 0.92)
    }));
    
    $context->range_axis->format('%d');
    $context->range_axis->fudge_amount(0.1);

    my @series;
    foreach my $s ( @{ $c->stash->{data}->{series} } ) {
        push(@series, Chart::Clicker::Data::Series->new(%{ $s }));
    }
    my $ds = Chart::Clicker::Data::DataSet->new( series => \@series );
    
    $cc->add_to_datasets($ds);
    
    $cc->draw;
    
    $c->res->body($cc->data);
}



1;