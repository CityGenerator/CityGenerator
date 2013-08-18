#!/usr/bin/perl -wT
package LegendGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_legend );

###############################################################################

=head1 NAME

    LegendGenerator - used to generate Legends

=head1 SYNOPSIS

    use LegendGenerator;
    my $legend1=LegendGenerator::create_legend();
    my $legend2=LegendGenerator::create_legend($parameters);

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object );
use List::Util 'shuffle', 'min', 'max';
use CityGenerator;
use NPCGenerator;
use POSIX;
use Template;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by LegendGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/legends.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################

my $xml_data      = $xml->XMLin( "xml/data.xml",    ForceContent => 1, ForceArray => ['option'] );
my $legend_data    = $xml->XMLin( "xml/legends.xml",  ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the legend structure.

=head3 create_legend()

This method is used to create a simple legend with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create_legend {
    my ($params) = @_;
    my $legend = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $legend->{$key} = $params->{$key};
        }
    }

    if ( !defined $legend->{'seed'} ) {
        $legend->{'seed'} = GenericGenerator::set_seed();
    }
    GenericGenerator::set_seed( $legend->{'seed'} );

    GenericGenerator::select_features($legend,$legend_data);

    $legend->{'npc'}=NPCGenerator::create_npc() if (!defined $legend->{'npc'});
    $legend->{'villain'}=NPCGenerator::create_npc({ 'available_races'=>['mindflayer','minotaur','kobold', 'goblin','lizardfolk','troglodyte', 'ogre', 'orc']  }) if (!defined $legend->{'villain'});
    $legend->{'location'}=CityGenerator::generate_city_name({ 'seed'=>$legend->{'seed'}} ) if (!defined $legend->{'location'});

    GenericGenerator::parse_template($legend, 'template');
    GenericGenerator::parse_template($legend, 'template');
    return $legend;
}



1;

__END__


=head1 AUTHOR

Jesse Morgan (morgajel)  C<< <morgajel@gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013, Jesse Morgan (morgajel) C<< <morgajel@gmail.com> >>. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation version 2
of the License.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=head1 DISCLAIMER OF WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
