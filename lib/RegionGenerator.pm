#!/usr/bin/perl -wT
###############################################################################

package RegionGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_region generate_name);

###############################################################################

=head1 NAME

    RegionGenerator - used to generate Regions

=head1 SYNOPSIS

    use RegionGenerator;
    my $region=RegionGenerator::create_region();

=cut

###############################################################################


use CGI;
use Data::Dumper;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/npcnames.xml>

=item F<xml/citynames.xml>

=item F<xml/regionames.xml>

=item F<xml/continentnames.xml>

=back

=cut

###############################################################################
# FIXME This needs to stop using our
my $xml_data            = $xml->XMLin( "xml/data.xml",           ForceContent => 1, ForceArray => ['option'] );
my $names_data          = $xml->XMLin( "xml/npcnames.xml",       ForceContent => 1, ForceArray => ['option'] );
my $citynames_data      = $xml->XMLin( "xml/citynames.xml",      ForceContent => 1, ForceArray => ['option'] );
my $regionnames_data    = $xml->XMLin( "xml/regionnames.xml",    ForceContent => 1, ForceArray => ['option'] );
my $continentnames_data = $xml->XMLin( "xml/continentnames.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################


=head2 create_region()

This method is used to create a simple region with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_region {
    my ($params) = @_;
    my $region = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $region->{$key} = $params->{$key};
        }
    }

    if ( !defined $region->{'seed'} ) {
        $region->{'seed'} = set_seed();
    }

    # This knocks off the city IDs
    $region->{'seed'} = $region->{'seed'} - $region->{'seed'} % 10;

    generate_region_name($region);

    return $region;
}


###############################################################################

=head2 generate_region_name()

    generate a name for the region.

=cut

###############################################################################
sub generate_region_name {
    my ($region) = @_;
    set_seed( $region->{'seed'} );
    my $nameobj = parse_object($regionnames_data);
    $region->{'name'} = $nameobj->{'content'} if ( !defined $region->{'name'} );
    return $region;
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
