#!/usr/bin/perl -wT
###############################################################################

package RegionGenerator;

###############################################################################

=head1 NAME

    RegionGenerator - used to generate Regions

=head1 DESCRIPTION

 This can be used to create a Region

=cut

###############################################################################

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( create_region generate_name);

use CGI;
use Data::Dumper;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator ;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/npcnames.xml>

=item F<xml/business.xml>

=item F<xml/citynames.xml>

=item F<xml/regionames.xml>

=item F<xml/continentnames.xml>

=back

=cut

###############################################################################
# FIXME This needs to stop using our
our $xml_data           = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );
our $names_data         = $xml->XMLin( "xml/npcnames.xml", ForceContent => 1, ForceArray => [] );
our $business_data      = $xml->XMLin( "xml/business.xml", ForceContent => 1, ForceArray => [] );
our $citynames_data     = $xml->XMLin( "xml/citynames.xml", ForceContent => 1, ForceArray => [] );
our $regionnames_data    = $xml->XMLin( "xml/regionnames.xml", ForceContent => 1, ForceArray => [] );
our $continentnames_data= $xml->XMLin( "xml/continentnames.xml", ForceContent => 1, ForceArray => [] );

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
    my $region={};

    if (ref $params eq 'HASH'){
        foreach my $key (sort keys %$params){
            $region->{$key}=$params->{$key};
        }
    }

    if(!defined $region->{'seed'}){
        $region->{'seed'}=set_seed();
    }
    # This knocks off the city IDs
    $region->{'seed'}=$region->{'seed'} - $region->{'seed'}%10 ;

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
    set_seed($region->{'seed'});
    my $nameobj= parse_object( $regionnames_data );
    $region->{'name'}=$nameobj->{'content'}   if (!defined $region->{'name'} );
    return $region;
}


1;
