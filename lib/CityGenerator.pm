#!/usr/bin/perl -wT
###############################################################################

package CityGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_city generate_name);

###############################################################################

=head1 NAME

    CityGenerator - used to generate Cities

=head1 SYNOPSIS

    use CityGenerator;
    my $city=CityGenerator::create_city();
  
=cut 

###############################################################################

#TODO treat certain data as stats, mil, auth, edu, etc.
use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator;
use RegionGenerator;
use ContinentGenerator;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item * F<xml/data.xml>

=item * F<xml/npcnames.xml>

=item * F<xml/business.xml>

=item * F<xml/citynames.xml>

=item * F<xml/regionnames.xml>

=item * F<xml/resources.xml>

=item * F<xml/continentnames.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################
my $xml_data            = $xml->XMLin( "xml/data.xml",           ForceContent => 1, ForceArray => ['option'] );
my $names_data          = $xml->XMLin( "xml/npcnames.xml",       ForceContent => 1, ForceArray => [] );
my $business_data       = $xml->XMLin( "xml/business.xml",       ForceContent => 1, ForceArray => [] );
my $citynames_data      = $xml->XMLin( "xml/citynames.xml",      ForceContent => 1, ForceArray => [] );
my $regionnames_data    = $xml->XMLin( "xml/regionnames.xml",    ForceContent => 1, ForceArray => [] );
my $resource_data       = $xml->XMLin( "xml/resources.xml",      ForceContent => 1, ForceArray => [] );
my $continentnames_data = $xml->XMLin( "xml/continentnames.xml", ForceContent => 1, ForceArray => [] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the city structure.


=head3 create_city()

This method is used to create a simple city with nothing more than:

=over

=item * a seed

=item * a name

=item * a city size classification

=item * a population estimation

=back

=cut

###############################################################################
sub create_city {
    my ($params) = @_;
    my $city = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $city->{$key} = $params->{$key};
        }
    }

    if ( !defined $city->{'seed'} ) {
        $city->{'seed'} = set_seed();
    }
    $city->{'original_seed'} = $city->{'seed'};

    generate_city_name($city);
    generate_base_stats($city);
    set_city_size($city);

    return $city;
} ## end sub create_city

###############################################################################

=head3 generate_base_stats()

    generate basic stats for a city.

=cut

###############################################################################
sub generate_base_stats {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );
    $city->{'education'} = d(11) - 5 if ( !defined $city->{'education'} );
    $city->{'authority'} = d(11) - 5 if ( !defined $city->{'authority'} );
    $city->{'magic'}     = d(11) - 5 if ( !defined $city->{'magic'} );
    $city->{'military'}  = d(11) - 5 if ( !defined $city->{'military'} );
    $city->{'tolerance'} = d(11) - 5 if ( !defined $city->{'tolerance'} );
    $city->{'economy'}   = d(11) - 5 if ( !defined $city->{'economy'} );

    return $city;
} ## end sub generate_base_stats



###############################################################################

=head3 generate_city_name()

    generate a name for the city.

=cut

###############################################################################
sub generate_city_name {
    my ($city) = @_;
    set_seed( $city->{'seed'} );
    my $nameobj = parse_object($citynames_data);
    $city->{'name'} = $nameobj->{'content'} if ( !defined $city->{'name'} );
    return $city;
} ## end sub generate_city_name

###############################################################################

=head3 set_city_size()

Find the size of the city by selecting from the citysize 
 list, then populate the size, gp limit, population, and size modifier.

=cut

###############################################################################
sub set_city_size {
    my ($city) = @_;
    set_seed( $city->{'seed'} );
    my $citysizelist = $xml_data->{'citysize'}->{'city'};

    my $citysize = roll_from_array( &d(100), $citysizelist );
    my $sizedelta = $citysize->{'maxpop'} - $citysize->{'minpop'};

    $city->{'size'}          = $citysize->{'size'}                    if ( !defined $city->{'size'} );
    $city->{'gplimit'}       = $citysize->{'gplimit'}                 if ( !defined $city->{'gplimit'} );
    $city->{'pop_estimate'}  = $citysize->{'minpop'} + &d($sizedelta) if ( !defined $city->{'pop_estimate'} );
    $city->{'size_modifier'} = $citysize->{'size_modifier'}           if ( !defined $city->{'size_modifier'} );
    return $city;
} ## end sub set_city_size


###############################################################################

=head2 Secondary Methods

The following methods are used to flesh out the city.

=head3 flesh_out_city()

Add the other features beyond the core city.

=cut

###############################################################################
sub flesh_out_city {
    my ($city) = @_;
    set_seed( $city->{'seed'} );
    $city->{'region'}    = RegionGenerator::create_region( $city->{'seed'} );
    $city->{'continent'} = ContinentGenerator::create_continent( $city->{'seed'} );

    return $city;
} ## end sub flesh_out_city

###############################################################################

=head3 set_pop_type()

Find the type of city by selecting it from the citytype list, Then populate 
the base population, type, description and whether or not it's a mixed city.

=cut

###############################################################################
sub set_pop_type {
    my ($city) = @_;
    my $citytypelist = $xml_data->{'pop_types'}->{'pop_type'};
    my $citytype = roll_from_array( &d(100), $citytypelist );
    $city->{'base_pop'}    = $citytype->{'base_pop'}  if ( !defined $city->{'base_pop'} );
    $city->{'type'}        = $citytype->{'type'}      if ( !defined $city->{'type'} );
    $city->{'description'} = $citytype->{'content'}   if ( !defined $city->{'description'} );
    $city->{'add_other'}   = $citytype->{'add_other'} if ( !defined $city->{'add_other'} );
    return $city;
} ## end sub set_pop_type



###############################################################################

=head3 generate_walls()

Determine information about the streets. 

=cut

###############################################################################
sub generate_walls {
    my ($city) = @_;

    # chance of -25 to +60
    my $modifier = $city->{'size_modifier'} || 0;

    $city->{'wall_chance_roll'} = &d(100) - ($modifier) * 5;

    if ( $city->{'wall_chance_roll'} <= $xml_data->{'walls'}->{'chance'} ) {
        $city->{'wall_size_roll'} = &d(100) + $modifier;
        my $wall = roll_from_array( $city->{'wall_size_roll'}, $xml_data->{'walls'}->{'wall'} );
        $city->{'walls'} = parse_object($wall);
        $city->{'walls'}->{'height'}
            = $wall->{'heightmin'} + &d( $wall->{'heightmax'} - $wall->{'heightmin'} ) + $modifier;

    } else {
        $city->{'walls'}->{'content'} = "none";
        $city->{'walls'}->{'height'}  = 0;
    }
    return $city;
} ## end sub generate_walls


###############################################################################

=head3 set_laws()

Set the laws for the city.

=cut

###############################################################################

sub set_laws {
    my ($city) = @_;

    for my $facet ( keys %{ $xml_data->{'laws'} } ) {
        my $facetlist = $xml_data->{'laws'}->{$facet}->{'option'};
        $city->{'laws'}->{$facet} = rand_from_array($facetlist)->{'content'} if ( !defined $city->{'laws'}->{$facet} );
    }
    return $city;
} ## end sub set_laws

###############################################################################

=head3 set_age()

Set the current age of the city

=cut

###############################################################################
sub set_age {
    my ($city) = @_;

    my $agelist = $xml_data->{'cityages'}->{'cityage'};
    $city->{'age_roll'} = d(100) + $city->{'size_modifier'} if ( !defined $city->{'age_roll'} );

    my $result = roll_from_array( $city->{'age_roll'}, $agelist );
    $city->{'age_description'} = $result->{'content'} if ( !defined $city->{'age_description'} );
    $city->{'age_mod'}         = $result->{'age_mod'} if ( !defined $city->{'age_mod'} );
    return $city;
} ## end sub set_age


###############################################################################

=head3 generate_resources()

select resources modified by city size.
TODO How do I really want to weight resource allocation?

=cut

###############################################################################

sub generate_resources {
    my ($city) = @_;

    set_seed( $city->{'seed'} );

    #ensure that the resource count is at most 13 and at least 2
    #shift from 2-13 to 1-12, then take a number from 1-12 total.
    my $resource_count = d( min( max( $city->{'size_modifier'} + ( $city->{'economy'} || 0 ), 2 ), 13 ) );

    $city->{'resourcecount'} = $resource_count if ( !defined $city->{'resourcecount'} );

    #resetting $resource_count to reflect potential existing value.
    $resource_count = $city->{'resourcecount'};

    if ( !defined $city->{'resources'} || ref $city->{'resources'} ne 'ARRAY' ) {
        $city->{'resources'} = [];
        while ( $resource_count-- > 0 ) {
            GenericGenerator::set_seed( GenericGenerator::get_seed() + 1 );
            my $resource = rand_from_array( $resource_data->{'resource'} );
            push @{ $city->{'resources'} }, parse_object($resource);
        }
    } ## end if ( !defined $city->{...})
    return $city;
} ## end sub generate_resources



###############################################################################

=head2 generate_city_crest()

generate colors and the design

=cut

###############################################################################

sub generate_city_crest {
    my ($city) = @_;
    $city->{'crest'}={};
    #TODO finish this later, possibly as CrestGenerator
    return $city;
}


###############################################################################

=head2 generate_shape()

generate the rough shape of the city.

=cut

###############################################################################

sub generate_shape {
    my ($city) = @_;
    $city->{'shape'}=rand_from_array($xml_data->{'cityshape'}->{'option'})->{'content'}  if (!defined  $city->{'shape'} )  ;
    return $city;
}


###############################################################################

=head2 generate_city_age()

a simple selector

=cut

###############################################################################
sub generate_city_age {
    my ($city) = @_;

    $city->{'city_age'}= rand_from_array(   $xml_data->{'cityages'}->{'cityage'}  ) if (!defined  $city->{'city_age'});
    return $city;
}





1;

__END__


=head1 AUTHOR

Jesse Morgan (morgajel)  C<< <morgajel@gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, Jesse Morgan (morgajel) C<< <morgajel@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
