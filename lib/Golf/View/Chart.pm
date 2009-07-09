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

sub _load {
    my ($self, $type) = @_;
    Class::MOP::load_class($type) unless Class::MOP::is_class_loaded($type);
    
}
sub process {
    my ( $self, $c ) = @_;
    
    my $D = $c->stash->{data};
    $D->{options} ||= {};
    $D->{serie_type} ||= 'Series';

    my $cc = Chart::Clicker->new( 
        format => 'svg',
        %{ $D->{options} }
    );
    
    if ($D->{options}->{format} eq 'png') {
        $c->res->content_type('image/png');
    } else {
        $c->res->content_type('image/svg+xml');
    }
    
    my $context = $cc->get_context('default'); #Chart::Clicker::Context->new( name => 'default' );

    if (my $a = $D->{axis}->{domain}) {
        my $type = 'Chart::Clicker::Axis' . ($a->{type} ? '::' . $a->{type} : '');
        $self->_load($type);
        $context->domain_axis($type->new(
            orientation => 'horizontal',
            position => 'bottom',
            %{ $a->{args} }
        ));
    }

    if (my $markers = $D->{marker}) {
        my @markers = (ref($markers) eq 'ARRAY' ? @$markers : ($markers));
        foreach my $marker (@markers) {
            $c->log->debug('marker: ' . $marker) if $c->debug;
            my $mark = Chart::Clicker::Data::Marker->new(
                color   => Graphics::Color::RGB->new(red => 0.95, green => 0.94, blue => 0.0),
                brush  => Graphics::Primitive::Brush->new({
                    width => 3,
                }),
                %{ $marker },
             );
            $context->add_marker($mark);
        }
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

    {
        my @series;
        my $type = 'Chart::Clicker::Data::' . $D->{serie_type};
        $self->_load($type);
        foreach my $s ( @{ $c->stash->{data}->{series} } ) {
            push(@series, $type->new(%{ $s }));
        }
        my $ds = Chart::Clicker::Data::DataSet->new( series => \@series );
        $cc->add_to_datasets($ds);
        
    }

    if (my $chart = $D->{chart}) {
        my $type = 'Chart::Clicker::Renderer::' . $chart->{type};
        $self->_load($type);
        $context->renderer( $type->new($chart->{args} || () ) );
    } else {
        # fix up the default renderer somewhat :p
        $context->renderer->shape(Geometry::Primitive::Circle->new({ radius => 5, }));
        $context->renderer->shape_brush(Graphics::Primitive::Brush->new({ 
            width => 1, 
            color => Graphics::Color::RGB->new(red => 0.95, green => 0.94, blue => 0.92)
        }));
    }
    
    $cc->draw;
    
    $c->res->body($cc->data);
}



1;