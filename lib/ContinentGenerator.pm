#!/usr/bin/perl -wT
###############################################################################

package ContinentGenerator;

###############################################################################

=head1 NAME

    ContinentGenerator - used to generate Continents

=head1 DESCRIPTION

 This can be used to create a Continent

=cut

###############################################################################

use strict;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( create_continent generate_name);

use CGI;
use Data::Dumper;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator ;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;

my $xml = new XML::Simple;

###############################################################################

=head1 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/npcnames.xml>

=item F<xml/business.xml>

=item F<xml/citynames.xml>

=item F<xml/regionnames.xml>

=item F<xml/continentnames.xml>

=back

=cut

###############################################################################
# FIXME This needs to stop using our
our $xml_data           = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );
our $names_data         = $xml->XMLin( "xml/npcnames.xml", ForceContent => 1, ForceArray => [] );
our $business_data      = $xml->XMLin( "xml/business.xml", ForceContent => 1, ForceArray => [] );
our $citynames_data     = $xml->XMLin( "xml/citynames.xml", ForceContent => 1, ForceArray => [] );
our $regionnames_data   = $xml->XMLin( "xml/regionnames.xml", ForceContent => 1, ForceArray => [] );
our $continentnames_data= $xml->XMLin( "xml/continentnames.xml", ForceContent => 1, ForceArray => [] );

###############################################################################


=head2 create_continent()

This method is used to create a simple continent with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_continent {
    my ($params) = @_;
    my $continent={};

    if (ref $params eq 'HASH'){
        foreach my $key (sort keys %$params){
            $continent->{$key}=$params->{$key};
        }
    }

    if(!defined $continent->{'seed'}){
        $continent->{'seed'}=set_seed();
    }
    # This knocks off the city IDs
    $continent->{'seed'}=$continent->{'seed'} - $continent->{'seed'}%100 ;

    generate_continent_name($continent);

    return $continent;
}


###############################################################################

=head2 generate_continent_name()

    generate a name for the continent.

=cut

###############################################################################
sub generate_continent_name {
    my ($continent) = @_;
    set_seed($continent->{'seed'});
    my $nameobj= parse_object( $continentnames_data );
    $continent->{'name'}=$nameobj->{'content'}   if (!defined $continent->{'name'} );
    
}


1;
