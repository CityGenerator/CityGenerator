#!/usr/bin/perl -wT
###############################################################################

package CityGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_city generate_city_name);

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
use AstronomyGenerator;
use ContinentGenerator;
use ClimateGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object seed);
use Math::Complex ':pi';
use NPCGenerator;
use PostingGenerator;
use RegionGenerator;
use GovtGenerator;
use MilitaryGenerator;
use EstablishmentGenerator;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item * F<xml/data.xml>

=item * F<xml/npcnames.xml>

=item * F<xml/citynames.xml>

=item * F<xml/regionnames.xml>

=item * F<xml/resources.xml>

=item * F<xml/continentnames.xml>

=item * F<xml/specialists.xml>

=item * F<xml/districts.xml>

=back

=head1 INTERFACE


=cut

###############################################################################
my $xml_data            = $xml->XMLin( "xml/data.xml",          ForceContent => 1, ForceArray => ['option'] );
my $names_data          = $xml->XMLin( "xml/npcnames.xml",      ForceContent => 1, ForceArray => ['option'] );
my $citynames_data      = $xml->XMLin( "xml/citynames.xml",     ForceContent => 1, ForceArray => ['option'] );
my $city_data           = $xml->XMLin( "xml/cities.xml",        ForceContent => 1, ForceArray => ['option'] );
my $resource_data       = $xml->XMLin( "xml/resources.xml",     ForceContent => 1, ForceArray => ['option'] );
my $specialist_data     = $xml->XMLin( "xml/specialists.xml",   ForceContent => 1, ForceArray => ['option'] );
my $district_data       = $xml->XMLin( "xml/districts.xml",     ForceContent => 1, ForceArray => ['option'] );

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

    #TODO$city= set_keys($params);
    #TODO GenericGenerator::set_keys

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $city->{$key} = $params->{$key};
        }
    }

    if ( !defined $city->{'seed'} ) {
        $city->{'seed'} = GenericGenerator::set_seed();
    }

    generate_city_name($city);
    GenericGenerator::generate_stats($city,$city_data);
    GenericGenerator::select_features($city,$city_data);

    set_city_size($city);

    return $city;
}


###############################################################################

=head3 generate_city_name()

    generate a name for the city.

=cut

###############################################################################
sub generate_city_name {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 1);
    $city->{'name'} = parse_object($citynames_data)->{'content'} if ( !defined $city->{'name'} );
    return $city;
}


###############################################################################

=head3 set_city_size()

Find the size of the city by selecting from the citysize 
 list, then populate the size, gp limit, population, and size modifier.

=cut

###############################################################################
sub set_city_size {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 2 );


    $city->{'size_roll'}= &d(100) if (!defined $city->{'size_roll'});

    my $citysize = roll_from_array( $city->{'size_roll'} , $city_data->{'size'}->{'option'} );

    my $sizedelta = $citysize->{'maxpop'} - $citysize->{'minpop'};

    $city->{'size'}          = $citysize->{'size'}                    if ( !defined $city->{'size'} );
    $city->{'gplimit'}       = $citysize->{'gplimit'}                 if ( !defined $city->{'gplimit'} );
    $city->{'pop_estimate'}  = $citysize->{'minpop'} + &d($sizedelta) if ( !defined $city->{'pop_estimate'} );
    $city->{'size_modifier'} = $citysize->{'size_modifier'}           if ( !defined $city->{'size_modifier'} );
    $city->{'min_density'}   = $citysize->{'min_density'}             if ( !defined $city->{'min_density'} );
    $city->{'max_density'}   = $citysize->{'max_density'}             if ( !defined $city->{'max_density'} );
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
    GenericGenerator::set_seed( $city->{'seed'} + 3 );
    $city->{'region'}    = RegionGenerator::create_region( $city->{'seed'} )  if (!defined $city->{'region'});
    $city->{'continent'} = ContinentGenerator::create_continent( $city->{'seed'} ) if(!defined $city->{'continent'});

    # calculate population and race information
    set_pop_type($city);
    set_available_races($city);
    generate_race_percentages($city);
    set_races($city);
    recalculate_populations($city);
#    generate_citizens($city);
    generate_children($city);
    generate_elderly($city);
    generate_imprisonment_rate($city);

    generate_resources($city);
    generate_city_crest($city);
    generate_streets($city);
    set_laws($city);

    #Generate
    generate_popdensity($city);
    generate_area($city);
###    generate_walls($city);
###    generate_watchtowers($city);
    generate_housing($city);
###    generate_specialists($city);
###    generate_businesses($city);
###    generate_establishments($city);
    generate_postings($city);
###    generate_districts($city);
###
###
###    generate_travelers($city);
###    generate_crime($city);
    set_dominance($city);
###
###    $city->{'govt'}      = GovtGenerator::create_govt( {            'seed' => $city->{'seed'} } );
###    $city->{'military'}  = MilitaryGenerator::create_military( {    'seed' => $city->{'seed'}, 'population_total'=>$city->{'population_total'}  } );
###    $city->{'climate'}   = ClimateGenerator::create_climate( {      'seed' => $city->{'seed'} } );
###    $city->{'climate'}   = ClimateGenerator::flesh_out_climate( $city->{'climate'} );
###    $city->{'astronomy'} = AstronomyGenerator::create_astronomy( $city->{'astronomy'} );
###
###
    return $city;
}

###############################################################################

=head3 set_pop_type()

Find the type of city by selecting it from the citytype list, Then populate 
the base population, type, description and whether or not it's a mixed city.

=cut

###############################################################################
sub set_pop_type {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 4);
    $city->{'poptype_roll'} = d(100)   if ( !defined $city->{'poptype_roll'} );
    $city->{'poptype'} = roll_from_array( $city->{'poptype_roll'}, $city_data->{'poptype'}->{'option'} )->{'content'} if (!defined $city->{'poptype'} );

    return $city;
} ## end sub set_pop_type


###############################################################################

=head2 set_available_races()

select the races that are available for the city's poptype.

=cut

###############################################################################
sub set_available_races {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 5 );

    if ( !defined $city->{'available_races'} ) {
        $city->{'available_races'} = [];
        foreach my $racename ( keys %{ $names_data->{'race'} } ) {
            my $race = $names_data->{'race'}->{$racename};
            if ( $race->{'type'} eq $city->{'poptype'} or $city->{'poptype'} eq 'mixed' ) {
                push @{ $city->{'available_races'} }, $racename;
            }
        }
    }
    $city->{'available_races'} = [shuffle @{ $city->{'available_races'} } ];

    return $city;
}


###############################################################################

=head2 generate_race_percentages

select the percentages used for each race.

=cut

###############################################################################
sub generate_race_percentages {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 6 );

    $city->{'race_limit'} = 6 if (!defined $city->{'race_limit'});

    my $total_percent = 0;

    if ( !defined $city->{'race percentages'} ) {

        $city->{'race percentages'} = [];

        while (  ($city->{'race_limit'}  > scalar( @{ $city->{'race percentages'} } ) )
                and  $total_percent < 98 ) {

            # Of the total amount or percentage left, how much is for this race?
            my $race_percent = max( 1, int( rand() * ( 100 - $total_percent ) * 10 ) / 10 );

            # Add to percentage
            $total_percent += $race_percent;

            # Add it to our array for later usage
            push @{ $city->{'race percentages'} }, $race_percent;
        }
    }

    # sort whatever is left.
    $city->{'race percentages'} = [ sort @{ $city->{'race percentages'} } ];


    return $city;
}


###############################################################################

=head2 set_races

set the races and percentages with the population.
WARNING: it is totally possible to pass in bad percentages. these should be
ironed out in the recalculation.

=cut

###############################################################################
sub set_races {
    my ($city) = @_;

    GenericGenerator::set_seed( $city->{'seed'} + 7 );
    $city->{'races'} =[] if (!defined $city->{'races'} );

    my $totalpercent = 0;
    # ensure we save space for one "other"
    $city->{'population_total'} = 1;

    # Grab our list of available races.
    my @racenames = @{ $city->{'available_races'} };

    my $id=0;
    foreach my $racepercent ( sort { $b <=> $a } @{ $city->{'race percentages'} } ) {

        my $racename   = pop @racenames;
        my $population = ceil( $racepercent * $city->{'pop_estimate'} / 100 );

        $city->{'races'}->[$id]                 = {}            if (!defined $city->{'races'}->[$id]);
        $city->{'races'}->[$id]->{'race'}       = $racename     if (!defined $city->{'races'}->[$id]->{'race'});
        $city->{'races'}->[$id]->{'percent'}    = $racepercent  if (!defined $city->{'races'}->[$id]->{'percent'});
        $city->{'races'}->[$id]->{'population'} = $population   if (!defined $city->{'races'}->[$id]->{'population'});
        
        $totalpercent               += $city->{'races'}->[$id]->{'percent'};
        $city->{'population_total'} += $city->{'races'}->[$id]->{'population'};
        $id++;
    }
    # remove the 1 we added above
    $city->{'population_total'}--;
    $city->{'races'}->[$id]                 = {}                                                            if (!defined $city->{'races'}->[$id]);
    $city->{'races'}->[$id]->{'race'}       = 'other'                                                       if (!defined $city->{'races'}->[$id]->{'race'});
    $city->{'races'}->[$id]->{'percent'}    = max(1, 100 - $totalpercent )                                  if (!defined $city->{'races'}->[$id]->{'percent'});
    $city->{'races'}->[$id]->{'population'} = max(1,$city->{'pop_estimate'} - $city->{'population_total'})  if (!defined $city->{'races'}->[$id]->{'population'});
    $city->{'population_total'} += $city->{'races'}->[$id]->{'population'};

    return $city;
}


###############################################################################

=head2 recalculate_populations

Given the races and percentages, recalculate the total number of each.

=cut

###############################################################################
sub recalculate_populations {

    #TODO needs to account for existing values
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 8);
    foreach my $race ( @{ $city->{'races'} } ) {
        $race->{'percent'} = $race->{'population'} / $city->{'population_total'};
        $race->{'percent'} = int( $race->{'percent'} * 1000 ) / 10;
    }
    return $city;
}

##################################################################################
###
###=head2 generate_citizens
###
###Generate a list of citizens.
###=cut
###
##################################################################################
#### TODO can this be refactored in a sane way with establishments and other "lists" of generator output?
###sub generate_citizens {
###    my ($city) = @_;
###    GenericGenerator::set_seed( $city->{'seed'}  + 9);
###
###    
###    $city->{'citizen_count'} = 8 + floor( ($city->{'size_modifier'} + 5)*1.2) if ( !defined $city->{'citizen_count'} );
###
###    if ( !defined $city->{'citizens'} ) {
###        $city->{'citizens'} = [];
###        for ( my $i = 0 ; $i < $city->{'citizen_count'} ; $i++ ) {
###            push @{ $city->{'citizens'} },
###                NPCGenerator::create_npc( { 'available_races' => $city->{'available_races'} } );
###        }
###    }
###    print STDERR Dumper $city->{'available_races'};
###    return $city;
###}


###############################################################################

=head2 generate_children

generate the number of children.

=cut

###############################################################################

sub generate_children {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 10 );

    my $origvalue= $city->{'children'}->{'percent'} if (defined $city->{'children'}->{'percent'});

    #calculate the pop based on 10 +age stat; should give us a rage between
    # 10% and 45%, which follows the reported international rates of the US census bureau, so STFU.
    $city->{'children'}->{'percent'} = 10 + 35*(100 - $city->{'stats'}->{'age'})/100
        if ( !defined $city->{'children'}->{'percent'} );

    #calculate out the actual child population in whole numbers
    $city->{'children'}->{'population'} = int( $city->{'children'}->{'percent'} / 100 * $city->{'population_total'} )
        if ( !defined $city->{'children'}->{'population'} );

    #recalulate to make the percent accurate with the population
    $city->{'children'}->{'percent'} = sprintf "%0.2f",
        $city->{'children'}->{'population'} / $city->{'population_total'} * 100 if (!defined $origvalue);

    return $city;
}


###############################################################################

=head2 generate_elderly

generate the number of elderly.

=cut

###############################################################################

sub generate_elderly {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 11 );

    my $origvalue= $city->{'elderly'}->{'percent'} if (defined $city->{'elderly'}->{'percent'});

    #calculate the pop based on 10 +random factor - city age modifier; should give us a rage between
    # 1.5% and 26%, which follows the reported international rates of the US census bureau, so STFU.
    $city->{'elderly'}->{'percent'} =  1 + 25.0*( $city->{'stats'}->{'age'}  )/100
        if ( !defined $city->{'elderly'}->{'percent'} );

    #calculate out the actual child population in whole numbers
    $city->{'elderly'}->{'population'} = int( $city->{'elderly'}->{'percent'} / 100 * $city->{'population_total'} )
        if ( !defined $city->{'elderly'}->{'population'} );

    #recalulate to make the percent accurate with the population
    $city->{'elderly'}->{'percent'} = sprintf "%0.2f",
        $city->{'elderly'}->{'population'} / $city->{'population_total'} * 100 if(!defined $origvalue) ;
    return $city;
}

###############################################################################

=head2 generate_imprisonment_rate

generate the number of imprisonment_rate.

=cut

###############################################################################

sub generate_imprisonment_rate {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 15 );

    # @braddoro says you're an asshole for questioning this. Just accept it.
    my $rough_percent =  0.05 + (1.765*d(100)/100  ) ;
    $rough_percent=$city->{'imprisonment_rate'}->{'percent'} if (defined $city->{'imprisonment_rate'}->{'percent'});

    #calculate out the actual child population in whole numbers
    $city->{'imprisonment_rate'}->{'population'} = int( $rough_percent / 100 * $city->{'population_total'} )
        if ( !defined $city->{'imprisonment_rate'}->{'population'} );

    #recalulate to make the percent accurate with the population
    $city->{'imprisonment_rate'}->{'percent'} = sprintf "%0.2f",
        $city->{'imprisonment_rate'}->{'population'} / $city->{'population_total'} * 100
        if ( !defined $city->{'imprisonment_rate'}->{'percent'} );

    return $city;
}


###############################################################################

=head3 generate_resources()

select resources modified by city size.
TODO How do I really want to weight resource allocation?

=cut

###############################################################################

sub generate_resources {
    my ($city) = @_;

    GenericGenerator::set_seed( $city->{'seed'} + 16);

    #ensure that the resource count is at most 13 and at least 2
    #shift from 2-13 to 1-12, then take a number from 1-12 total.
    my $resource_count =  max( $city->{'size_modifier'} + 5, 5 ) ;

    $city->{'resourcecount'} = $resource_count if ( !defined $city->{'resourcecount'} );

    #resetting $resource_count to reflect potential existing value.
    $resource_count = $city->{'resourcecount'};

    if ( !defined $city->{'resources'} ) {
        $city->{'resources'} = [];
        while ( $resource_count-- > 0 ) {
            my $resource = rand_from_array( $resource_data->{'resource'} );
            push @{ $city->{'resources'} }, parse_object($resource);
        }
    }
    return $city;
}


###############################################################################

=head2 generate_city_crest()

generate colors and the design

=cut

###############################################################################

sub generate_city_crest {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 17 );
    $city->{'crest'} = {};

    #TODO finish this later, possibly as CrestGenerator
    return $city;
}


###############################################################################

=head2 generate_streets

Generate details on the streets

=cut

###############################################################################
sub generate_streets {

    #TODO needs to account for existing values
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 19 );

    $city->{'streets'}->{'content'} = parse_object( $city_data->{'streets'} )->{'content'}
        if ( !defined $city->{'streets'}->{'content'} );


    $city->{'streets'}->{'mainroads'} = d(5)-1     if ( !defined $city->{'streets'}->{'mainroads'} );
    $city->{'streets'}->{'roads'} = d(4) + $city->{'streets'}->{'mainroads'}
        if ( !defined $city->{'streets'}->{'roads'} );

    return $city;
}


###############################################################################

=head2 generate_popdensity

Generate the density of the population, given the base city size. Units are people per sq km.
=cut

###############################################################################
sub generate_popdensity {

    # TODO addmagic, economey, etc to impact density
    #TODO change how this is calculated and get rid of delta in favor of a percentile range multiplier
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 25);
    my $range = $city->{'max_density'} - $city->{'min_density'};
    my $delta = &d($range);
    $city->{'population_density'} = $city->{'min_density'} + $delta if ( !defined $city->{'population_density'} );

    my $percentile = ( $city->{'population_density'} - $city->{'min_density'} ) / $range * 100;
    $city->{'density_description'} = roll_from_array( $percentile, $city_data->{'popdensity'}->{'option'} )->{'type'}
        if ( !defined $city->{'density_description'} );

    return $city;
}



##################################################################################
###
###=head3 generate_walls()
###
###Determine information about the streets. 
###
###=cut
###
##################################################################################
###sub generate_walls {
###    #TODO refactor this method.... it's fugly.
###    my ($city) = @_;
###    GenericGenerator::set_seed( $city->{'seed'} + 20 );
###
###    # chance of -25 to +60
###    my $modifier = $city->{'size_modifier'};
###
###    # Find a better way to determine if there's a wall.
###    $city->{'wall_chance_roll'} = &d(100) - ($modifier) * 5 if ( !defined $city->{'wall_chance_roll'} );
###    if ( $city->{'wall_chance_roll'} <= $xml_data->{'walls'}->{'chance'} ) {
###
###        $city->{'walls'}->{'condition'} = roll_from_array(d(100), $xml_data->{'walls'}->{'condition'}->{'option'})->{'content'} if (!defined $city->{'walls'}->{'condition'});
###        $city->{'walls'}->{'style'}     = roll_from_array(d(100), $xml_data->{'walls'}->{'style'}->{'option'})->{'content'} if (!defined $city->{'walls'}->{'style'});
###        my $material                    = roll_from_array(d(100), $xml_data->{'walls'}->{'material'}->{'option'});
###        $city->{'walls'}->{'material'}  = $material->{'content'} if (!defined $city->{'walls'}->{'material'});
###
###        $city->{'walls'}->{'height'}    = int (rand( $material->{'maxheight'} - $material->{'minheight'} ) + $material->{'minheight'}  ) if (!defined  $city->{'walls'}->{'height'});
###
###        $city->{'protected_percent'} = min( 100, 70 + d(30) + $city->{'stats'}->{'military'} )
###            if ( !defined $city->{'protected_percent'} );
###
###    print STDERR Dumper $city->{'area'} ;
###
###        $city->{'protected_area'} = sprintf( "%4.2f", ( $city->{'area'} * $city->{'protected_percent'} / 100 ) )
###            if ( !defined $city->{'protected_area'} );
###
###        my $radius = sqrt( $city->{'protected_area'} / pi );
###        $city->{'walls'}->{'length'} = sprintf "%4.2f", 2 * pi * $radius * ( 100 + d(40) ) / 100;
###    } else {
###        $city->{'walls'}->{'height'}  = 0;
###    }
###    return $city;
###}


##################################################################################
###
###=head3 generate_watchtowers()
###
###Determine information about the city watchtowers.
###
###=cut
###
##################################################################################
###sub generate_watchtowers {
###    my ($city) = @_;
###    GenericGenerator::set_seed( $city->{'seed'} + 21 );
###
###    #FIXME this shouldn't be hardcoded to 5
###    $city->{'watchtowers'}->{'count'} = 5;
###
###    return $city;
###}
###
###
###############################################################################

=head3 set_laws()

Set the laws for the city.

=cut

###############################################################################

sub set_laws {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 22 );

    for my $facet ( keys %{ $xml_data->{'laws'} } ) {
        my $facetlist = $xml_data->{'laws'}->{$facet}->{'option'};
        $city->{'laws'}->{$facet} = rand_from_array($facetlist)->{'content'} if ( !defined $city->{'laws'}->{$facet} );
    }
    return $city;
} ## end sub set_laws


###############################################################################

=head2 generate_area

Generate the area the city covers.

=cut

###############################################################################
sub generate_area {

    #TODO change to metric....
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 24 );
    $city->{'area'} = sprintf "%4.2f", $city->{'population_total'} / $city->{'population_density'} if (!defined $city->{'area'});

    #3-300/3=1-100= * + 50= 51-150 /100 = .5-1.5

    my $stat_modifier = (($city->{'stats'}->{'education'} + $city->{'stats'}->{'economy'} + $city->{'stats'}->{'magic'})/3 +50)/100  ;

    $city->{'arable_percentage'} = max( 1, min( 100, d(100)* $stat_modifier  ) )
        if ( !defined $city->{'arable_percentage'} );

    $city->{'arable_description'}
        = roll_from_array( $city->{'arable_percentage'}, $city_data->{'arable'}->{'option'} )->{'content'}
        if ( !defined $city->{'arable_description'} );


    return $city;
}



##################################################################################
###
###=head2 generate_specialists
###
###Generate a list of specialists.
###
###=cut
###
##################################################################################
###sub generate_specialists {
###    my ($city) = @_;
###    GenericGenerator::set_seed( $city->{'seed'} + 26);
###
###    if ( !defined $city->{'specialists'} ) {
###        $city->{'specialists'} = {};
###    }
###
###    $city->{'specialist_total'} = 0;
###
###    foreach my $specialist_name ( sort keys %{ $specialist_data->{'option'} } ) {
###        if ( !defined $city->{'specialists'}->{$specialist_name} ) {
###
###            my $specialist = $specialist_data->{'option'}->{$specialist_name};
###            if ( $specialist->{'sv'} <= $city->{'population_total'} ) {
###                $city->{'specialists'}->{$specialist_name}
###                    = { 'count' => floor( $city->{'population_total'} / $specialist->{'sv'} ), };
###                $city->{'specialist_total'} += $city->{'specialists'}->{$specialist_name}->{'count'};
###            } else {
###
###                if ( &d( $specialist->{'sv'} ) == 1 ) {
###                    $city->{'specialists'}->{$specialist_name} = { 'count' => 1 };
###                    $city->{'specialist_total'} += $city->{'specialists'}->{$specialist_name}->{'count'};
###                }
###            }
###        }
###    }
###
###
###    return $city;
###}
###
##################################################################################
###
###=head2 generate_businesses
###
###Generate a list of businesses from existing specialists
###
###=cut
###
##################################################################################
###
###
###sub generate_businesses {
###    my ($city) = @_;
###    GenericGenerator::set_seed( $city->{'seed'} + 27);
###    if ( !defined $city->{'businesses'} ) {
###        $city->{'businesses'} = {};
###    }
###    $city->{'business_total'} = 0;
###    foreach my $specialist_name ( sort keys %{ $city->{'specialists'} } ) {
###        my $specialist = $specialist_data->{'option'}->{$specialist_name};
###
###        # Check to see if the specialist has a building associated with it.
###        if ( defined $specialist->{'building'} ) {
###            my $building = $specialist->{'building'};
###            $city->{'businesses'}->{$building}->{'perbuilding'}
###                = $specialist_data->{'option'}->{$specialist_name}->{'perbuilding'};
###            $city->{'businesses'}->{$building}->{'district'}
###                = $specialist_data->{'option'}->{$specialist_name}->{'district'};
###            if ( defined $city->{'businesses'}->{$building}->{'specialist_count'} ) {
###                $city->{'businesses'}->{$building}->{'specialist_count'}
###                    += $city->{'specialists'}->{$specialist_name}->{'count'};
###            } else {
###                $city->{'businesses'}->{$building}->{'specialist_count'}
###                    = $city->{'specialists'}->{$specialist_name}->{'count'};
###            }
###        }
###    }
###
###    foreach my $business_name ( keys %{ $city->{'businesses'} } ) {
###        my $business = $city->{'businesses'}->{$business_name};
###        $city->{'businesses'}->{$business_name}->{'count'}
###            = ceil( $business->{'specialist_count'} / $business->{'perbuilding'} );
###        $city->{'business_total'} += $city->{'businesses'}->{$business_name}->{'count'};
###    }
###
###    return $city;
###}
###
###
##################################################################################
###
###=head2 generate_districts
###
###Generate a list of districts from existing businesses
###
###=cut
###
##################################################################################
###
###
###sub generate_districts {
###    my ($city) = @_;
###    GenericGenerator::set_seed( $city->{'seed'} + 29);
###
###    my $district_percents = {};
###
###    #loop through our businesses and add up modifiers for district percents
###    foreach my $business_name ( keys %{ $city->{'businesses'} } ) {
###        my $business      = $city->{'businesses'}->{$business_name};
###        my $district_name = $business->{'district'};
###        $district_percents->{$district_name}
###            += ( defined $district_percents->{$district_name} ) ? &d( $business->{'count'} ) : 0;
###    }
###
###    foreach my $district_name ( keys %{ $district_data->{'option'} } ) {
###        my $district = $district_data->{'option'}->{$district_name};
###
###        my $district_modifier
###            = ( defined $district_percents->{$district_name} ) ? $district_percents->{$district_name} : 0;
###        my $district_roll = &d(100);
###
###        # modify our district chance in the xml by our district_modifier
###        if ( $district_roll <= $district->{'chance'} + $district_modifier + $city->{'size_modifier'} ) {
###            $city->{'districts'}->{$district_name}->{'stat'}           = $district->{'stat'};
###            $city->{'districts'}->{$district_name}->{'business_count'} = $district_modifier;
###        }
###
###    }
###    return $city;
###}
##################################################################################
###
###=head2 generate_travelers
###
###Generate a list of travelers.
###
###=cut
###
##################################################################################
###sub generate_travelers {
###    my ($city) = @_;
###
###    # NOTE adding offset of 10 to ensure travelers are not the same races as citizens...
###    GenericGenerator::set_seed( $city->{'seed'} + 30 );
###
###    $city->{'traveler_count'} = 5 + $city->{'stats'}->{'tolerance'} if ( !defined $city->{'traveler_count'} );
###    if ( !defined $city->{'available_traveler_races'} ) {
###
###        #If tolerance is negative, only city races are allowed inside.
###        if ( $city->{'stats'}->{'tolerance'} < 0 ) {
###            $city->{'available_traveler_races'} = $city->{'available_races'};
###        } else {
###            $city->{'available_traveler_races'} = [ keys %{ $names_data->{'race'} } ];
###        }
###    }
###
###    if ( !defined $city->{'travelers'} ) {
###        $city->{'travelers'} = [];
###        for ( my $i = 0 ; $i < $city->{'traveler_count'} ; $i++ ) {
###            push @{ $city->{'travelers'} },
###                NPCGenerator::create_npc( { 'available_races' => $city->{'available_traveler_races'} } );
###        }
###    }
###    return $city;
###}
###
##################################################################################
###
###=head2 generate_crime
###
###Generate the crime rate
###
###=cut
###
##################################################################################
###sub generate_crime {
###    my ($city) = @_;
###    GenericGenerator::set_seed( $city->{'seed'} + 31);
###
###    my $moralmod = int( ( $city->{'moral'} - 50 ) / 10 );
###
###    $city->{'crime_roll'}
###        = min(100, max(1,int( &d(100) - $city->{'stats'}->{'education'} + $city->{'stats'}->{'authority'} + $moralmod )))
###        if ( !defined $city->{'crime_roll'} );
###    $city->{'crime_description'}
###        = roll_from_array( $city->{'crime_roll'}, $xml_data->{'crime'}->{'option'} )->{'content'}
###        if ( !defined $city->{'crime_description'} );
###
###    return $city;
###}


###############################################################################

=head2 set_dominance

select a race to be dominant, as well as the level of dominance.

=cut

###############################################################################
sub set_dominance {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} +32);

    $city->{'dominance_chance'} = d(100) if ( !defined $city->{'dominance_chance'} );

    if ( $city->{'dominance_chance'} < $xml_data->{'dominance'}->{'chance'} ) {
        $city->{'dominant_race'} = rand_from_array( $city->{'races'} )->{'race'}
            if ( !defined $city->{'dominant_race'} );
        $city->{'dominance_level'} = d(100) * ((100-$city->{'stats'}->{'tolerance'}) + 50)/100
            if ( !defined $city->{'dominance_level'} );
        my $dominance_option = roll_from_array( $city->{'dominance_level'}, $city_data->{'dominance'}->{'option'} );
        $city->{'dominance_description'} = $dominance_option->{'content'}
            if ( !defined $city->{'dominance_description'} );
    }
    return $city;
}

###############################################################################

=head2 generate_housing

generate the number of houses for the population

=cut

###############################################################################

sub generate_housing {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 33);

    my $housing_quality = $xml_data->{'housing'}->{'quality'};
    my $econmultiplier         = ($city->{'stats'}->{'economy'}+50)/100;

    # ranges from 20% to 60% good to bad econ
    $city->{'housing'}->{'poor_percent'} = $housing_quality->{'poor'}->{'percent'}/ $econmultiplier
        if ( !defined $city->{'housing'}->{'poor_percent'} );
    # ranges from 3% to 1%  good to bad econ
    $city->{'housing'}->{'wealthy_percent'} = $housing_quality->{'wealthy'}->{'percent'} * $econmultiplier
        if ( !defined $city->{'housing'}->{'wealthy_percent'} );

    # ranges from 77% to 38% good to bad
    $city->{'housing'}->{'average_percent'} = 100 - $city->{'housing'}->{'wealthy_percent'} - $city->{'housing'}->{'poor_percent'}
        if ( !defined $city->{'housing'}->{'average_percent'} );

    # ((100-econ)/60+1)^4
    # this scales nicely from 1% to 11.3% to 50.5%
    #                        Good   neutral  bad
    $city->{'housing'}->{'abandoned_percent'} = (1 + ((100-$city->{'stats'}->{'economy'})/60))**4   
        if ( !defined $city->{'housing'}->{'abandoned_percent'} );    # 1-21%

    my $total=0;
    foreach my $type (qw( poor average wealthy )){
        $city->{'housing'}->{$type.'_population'} = ceil( $city->{'population_total'} * $city->{'housing'}->{$type.'_percent'} / 100 )
            if ( !defined $city->{'housing'}->{$type.'_population'} );

        $city->{'housing'}->{$type} = ceil( $city->{'housing'}->{$type.'_population'} / $housing_quality->{$type}->{'density'} )
            if ( !defined $city->{'housing'}->{$type} );
        $total+=$city->{'housing'}->{$type};
    }

    $city->{'housing'}->{'total'} = $total if ( !defined $city->{'housing'}->{'total'} );
    $city->{'housing'}->{'abandoned'} = int( $city->{'housing'}->{'total'} * $city->{'housing'}->{'abandoned_percent'} / 100 );

    return $city;
}


##################################################################################
###
###=head2 generate_establishments
###
###Generate a list of establishments based on the business section
###
###=cut
###
##################################################################################
###
###
###sub generate_establishments {
###    my ($city) = @_;
###    GenericGenerator::set_seed( $city->{'seed'} + 34);
###
###    $city->{'establishments'} = [] if ( !defined $city->{'establishments'} );
###
###    if ( defined $city->{'businesses'} ) {
###        $city->{'establishment_count'} = 8 + floor( ($city->{'size_modifier'} + 5) * 1.2) if ( !defined $city->{'establishment_count'} );
###        my $patrons = floor($city->{'population_total'} / 3);
###        if ( $patrons > ($city->{'establishment_count'} * 3) ){
###            $patrons = $city->{'establishment_count'} * 3;
###        }
###        for ( my $establishmentID = 0 ; $establishmentID < $city->{'establishment_count'} ; $establishmentID++ ) {
###            if ( !defined $city->{'establishments'}->[$establishmentID] ) {
###                $city->{'establishments'}->[$establishmentID] = EstablishmentGenerator::create_establishment();
###                if( $patrons > 0 ) {
###                    my $roll = $patrons;
###                    if ($patrons > 10){
###                        $roll = 10;
###                    }
###                    my $occupants = d(floor($roll / 2));
###                    $city->{'establishments'}->[$establishmentID]->{'occupants'} = $occupants;
###                    $patrons = $patrons - $occupants;
###                }
###            }    
###        }
###    }
###    return $city;
###}


###############################################################################

=head2 generate_postings

Generate a list of postings based on the business section

=cut

###############################################################################
sub generate_postings {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 34);

    $city->{'postings'} = [] if ( !defined $city->{'postings'} );

    #ghetto, yes, but gives us a range of 6-23.
    $city->{'postingcount'}= $city->{'size_modifier'}+11 if (!defined $city->{'postingcount'});
    for ( my $postingID = 0 ; $postingID < $city->{'postingcount'} ; $postingID++ ) {
        $city->{'postings'}->[$postingID] = PostingGenerator::create_posting() if ( !defined $city->{'postings'}->[$postingID] );
    }
    return $city;
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
