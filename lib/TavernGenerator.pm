#!/usr/bin/perl -wT
###############################################################################

package TavernGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_tavern);

#TODO make generate_name method for use with namegenerator
###############################################################################

=head1 NAME

    TavernGenerator - used to generate Taverns

=head1 DESCRIPTION

 This can be used to create a Tavern

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/taverns.xml>

=back

=cut

###############################################################################

my $xml_data    = $xml->XMLin( "xml/data.xml",    ForceContent => 1, ForceArray => ['option'] );
my $tavern_data = $xml->XMLin( "xml/taverns.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################


=head2 create_tavern()

This method is used to create a simple tavern with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_tavern {
    my ($params) = @_;
    my $tavern = {};
    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $tavern->{$key} = $params->{$key};
        }
    }
    $tavern->{'seed'} = set_seed() if ( !defined $tavern->{'seed'} );


#Wet Frog is a average, respectable tavern where the middle-class gather. The bar is owned by a half-elf named Gwatinne Rootheart who seems mocking. The law accepts bribes from the patrons, however most violence is handled by swift justice. Goods are reasonably priced. You'll find 2 citizen(s) here.
    foreach my $stat (qw( reputation size cost popularity)) {
        $tavern->{'stats'}->{$stat} = d(100) if ( !defined $tavern->{'stats'}->{$stat} );
        $tavern->{ $stat . "_description" }
            = roll_from_array( $tavern->{'stats'}->{$stat}, $tavern_data->{$stat}->{'option'} )->{'content'}
            if ( !defined $tavern->{ $stat . "_description" } );
    }

    generate_tavern_name($tavern);
    generate_violence($tavern);
    generate_law($tavern);
    generate_bartender($tavern);
    generate_amenities($tavern);
    generate_atmosphere($tavern);

    # clientele, amenities, age
    # drinks? food?  stable?  privacy?  fireplace?  music?  inn beds?  gambling?

    return $tavern;
}


###############################################################################

=head2 generate_tavern_name()

    generate a name for the tavern.

=cut

###############################################################################
sub generate_tavern_name {
    my ($tavern) = @_;
    set_seed( $tavern->{'seed'} );
    my $nameobj = parse_object( $tavern_data->{'name'} );
    $tavern->{'name'} = $nameobj->{'content'} if ( !defined $tavern->{'name'} );
    return $tavern;
}


###############################################################################

=head2 generate_amenities()
 
generate the amenities
 
=cut

###############################################################################

sub generate_amenities {
    my ($tavern) = @_;

    $tavern->{'amenity_count'}
        = int(
        rand( $tavern_data->{'amenities'}->{'max'} - $tavern_data->{'amenities'}->{'min'} )
            + $tavern_data->{'amenities'}->{'min'} )
        if ( !defined $tavern->{'amenity_count'} );

    $tavern->{'amenity'} = [] if ( !defined $tavern->{'amenity'} );

    for ( my $amenityID = 0 ; $amenityID < $tavern->{'amenity_count'} ; $amenityID++ ) {
        $tavern->{'amenity'}->[$amenityID] = rand_from_array( $tavern_data->{'amenities'}->{'option'} )->{'content'}
            if ( !defined $tavern->{'amenity'}->[$amenityID] );
    }

    return $tavern;

}

###############################################################################

=head2 generate_violence()
 
generate the violence category of the tavern
 
=cut

###############################################################################

sub generate_violence {
    my ($tavern) = @_;

    $tavern->{'violence'} = rand_from_array( $tavern_data->{'violence'}->{'option'} )->{'type'}
        if ( !defined $tavern->{'violence'} );
    return $tavern;

}


###############################################################################

=head2 generate_law()
 
generate the law category of the tavern
 
=cut

###############################################################################

sub generate_law {
    my ($tavern) = @_;

    $tavern->{'law'} = rand_from_array( $tavern_data->{'law'}->{'option'} )->{'type'} if ( !defined $tavern->{'law'} );
    return $tavern;

}

###############################################################################

=head2 generate_atmosphere()
 
generate the atmosphere for the tavern
 
=cut

###############################################################################

sub generate_atmosphere {
    my ($tavern) = @_;

    $tavern->{'atmosphere'} = rand_from_array( $tavern_data->{'atmosphere'}->{'option'} )->{'type'} if ( !defined $tavern->{'atmosphere'} );
    return $tavern;

}


###############################################################################

=head2 generate_bartender()
 
generate the bartender for the tavern
 
=cut

###############################################################################

sub generate_bartender {
    my ($tavern) = @_;

    if ( !defined $tavern->{'bartender'} ) {

        $tavern->{'bartender'} = NPCGenerator::create_npc();

        #TODO flesh out npc here, need to add to NPCGenerator.
    }

    return $tavern;

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
