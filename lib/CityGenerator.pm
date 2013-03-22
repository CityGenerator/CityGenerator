#!/usr/bin/perl -wT
###############################################################################

package CityGenerator;

###############################################################################

=head1 NAME

    CityGenerator - used to generate Cities

=head1 DESCRIPTION

 This can be used to create a city.

=cut

###############################################################################

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( create_city generate_name);

use CGI;
use Data::Dumper;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator ;
use RegionGenerator ;
use ContinentGenerator ;
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

=item F<xml/regionnames.xml>

=item F<xml/resources.xml>

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
our $resource_data      = $xml->XMLin( "xml/resources.xml", ForceContent => 1, ForceArray => [] );
our $continentnames_data= $xml->XMLin( "xml/continentnames.xml", ForceContent => 1, ForceArray => [] );

###############################################################################

=head1 Core Methods

The following methods are used to create the core of the city structure.


=head2 create_city()

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
    my $city={};

    if (ref $params eq 'HASH'){
        foreach my $key (sort keys %$params){
            $city->{$key}=$params->{$key};
        }
    }

    if(!defined $city->{'seed'}){
        $city->{'seed'}=set_seed();
    }
    $city->{'original_seed'}=$city->{'seed'};

    generate_city_name($city);

    set_city_size($city);

    return $city;
}


###############################################################################

=head2 generate_city_name()

    generate a name for the city.

=cut

###############################################################################
sub generate_city_name {
    my ($city) = @_;
    set_seed($city->{'seed'});
    my $nameobj= parse_object( $citynames_data );
    $city->{'name'}=$nameobj->{'content'}   if (!defined $city->{'name'} );
    return $city;    
}

###############################################################################

=head2 set_city_size()

Find the size of the city by selecting from the citysize 
 list, then populate the size, gp limit, population, and size modifier.

=cut

###############################################################################
sub set_city_size {
    my ($city) = @_;
    set_seed( $city->{'seed'});
    my $citysizelist=$xml_data->{'citysize'}->{'city'} ;

    my $citysize = roll_from_array( &d(100), $citysizelist );
    my $sizedelta=$citysize->{'maxpop'} - $citysize->{'minpop'};

    $city->{'size'}             = $citysize->{'size'}                           if (!defined $city->{'size'}  );
    $city->{'gplimit'}          = $citysize->{'gplimit'}                        if (!defined $city->{'gplimit'}  );
    $city->{'pop_estimate'}     = $citysize->{'minpop'} + &d( $sizedelta )      if (!defined $city->{'pop_estimate'}  );
    $city->{'size_modifier'}    = $citysize->{'size_modifier'}                  if (!defined $city->{'size_modifier'}  );
    return $city;    
}


###############################################################################
=head1 Secondary Methods

The following methods are used to flesh out the city.

=head2 flesh_out_city()

Add the other features beyond the core city.

=cut

###############################################################################
sub flesh_out_city {
    my ($city) = @_;
    set_seed( $city->{'seed'});
    $city->{'region'}=RegionGenerator::create_region($city->{'seed'});
    $city->{'continent'}=ContinentGenerator::create_continent($city->{'seed'});

    return $city;    
}

###############################################################################

=head2 set_city_type()

Find the type of city by selecting it from the citytype list, Then populate 
the base population, type, description and whether or not it's a mixed city.

=cut

###############################################################################
sub set_city_type {
    my ($city)=@_;
    my $citytypelist=$xml_data->{'citytype'}->{'city'};
    my $citytype = roll_from_array( &d(100), $citytypelist );
    $city->{'base_pop'}    = $citytype->{'base_pop'}    if (!defined $city->{'base_pop'}  );
    $city->{'type'}        = $citytype->{'type'}        if (!defined $city->{'type'}  );
    $city->{'description'} = $citytype->{'content'}     if (!defined $city->{'description'}  );
    $city->{'add_other'}   = $citytype->{'add_other'}   if (!defined $city->{'add_other'}  );
    return $city;    
}

###############################################################################

=head2 generate_pop_type()

Generate a Population Type, then populate the population type, population 
 density, and a list of unassigned race percentages.

=cut

###############################################################################
sub generate_pop_type {
    my ($city)=@_;
    my $poptype     = roll_from_array( &d(100), $xml_data->{'poptypes'}->{'population'} );

    $city->{'popdensity'}   = rand_from_array( $xml_data->{'popdensity'}->{'option'} ) if (!defined $city->{'popdensity'} || ref $city->{'popdensity'} ne 'HASH'   );
    $city->{'poptype'}      = $poptype->{'type'}    if (!defined $city->{'poptype'}  );
    $city->{'races'}        = $poptype->{'option'}  if (!defined $city->{'races'} || ref $city->{'races'} ne 'ARRAY' );
    return $city;    
}


###############################################################################

=head2 generate_walls()

Determine information about the streets. 

=cut

###############################################################################
sub generate_walls {
    my($city)=@_;
    # chance of -25 to +60
    my $modifier=$city->{'size_modifier'}||0;

    $city->{'wall_chance_roll'}=&d(100)- ($modifier)*5 ;

    if($city->{'wall_chance_roll'}   <=  $xml_data->{'walls'}->{'chance'}){
        $city->{'wall_size_roll'}=&d(100) + $modifier;
        my $wall=roll_from_array( $city->{'wall_size_roll'} , $xml_data->{'walls'}->{'wall'}     );
        $city->{'walls'}=parse_object($wall);
        $city->{'walls'}->{'height'}= $wall->{'heightmin'}+  &d($wall->{'heightmax'}-$wall->{'heightmin'})   + $modifier;

    }else{
        $city->{'walls'}->{'content'}="none";
        $city->{'walls'}->{'height'}=0;
    }
    return $city;    
}




###############################################################################

=head2 set_laws()

Set the laws for the city.

=cut

###############################################################################

sub set_laws {
    my($city)=@_;

    for my $facet (keys %{$xml_data->{'laws'}}){
        my $facetlist=$xml_data->{'laws'}->{$facet}->{'option'};
        $city->{'laws'}->{$facet} = rand_from_array(  $facetlist  )->{'content'} if (!defined $city->{'laws'}->{$facet} )  ;
    }
    return $city;    
}

###############################################################################

=head2 set_age()

Set the current age of the city

=cut

###############################################################################
sub set_age {
    my($city)=@_;

    my $agelist=$xml_data->{'cityages'}->{'cityage'};
    $city->{'age_roll'}=d(100)+$city->{'size_modifier'} if (!defined $city->{'age_roll'});

    my $result= roll_from_array( $city->{'age_roll'}  , $agelist  );
    $city->{'age_description'}=$result->{'content'} if (!defined $city->{'age_description'});
    $city->{'age_mod'}=$result->{'age_mod'} if (!defined $city->{'age_mod'});
    return $city;    
}



###############################################################################

=head2 generate_resources()

select resources modified by city size.
TODO How do I really want to weight resource allocation

=cut

###############################################################################

sub generate_resources{
    my($city)=@_;

    set_seed( $city->{'seed'});
    #ensure that the resource count is at most 13 and at least 2
    #shift from 2-13 to 1-12, then take a number from 1-12 total.
    my $resource_count=d( min( max($city->{'size_modifier'}+($city->{'economy'}||0), 2 ),13) ) ;

    $city->{'resourcecount'}= $resource_count if (!defined $city->{'resourcecount'} );
    #resetting $resource_count to reflect potential existing value.
    $resource_count=$city->{'resourcecount'};

    if (!defined $city->{'resources'} || ref $city->{'resources'} ne 'ARRAY' ){
        $city->{'resources'}=[];
        while ($resource_count-- > 0 ){
            $GenericGenerator::seed++;
            my $resource=rand_from_array($resource_data->{'resource'});
            push @{ $city->{'resources'} }, parse_object($resource);
        }
    }
    return $city;    
}


1;
