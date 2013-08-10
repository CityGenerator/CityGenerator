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
use RegionGenerator;
use GovtGenerator;
use MilitaryGenerator;
use TavernGenerator;
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
my $xml_data            = $xml->XMLin( "xml/data.xml",           ForceContent => 1, ForceArray => ['option'] );
my $names_data          = $xml->XMLin( "xml/npcnames.xml",       ForceContent => 1, ForceArray => ['option'] );
my $citynames_data      = $xml->XMLin( "xml/citynames.xml",      ForceContent => 1, ForceArray => ['option'] );
my $resource_data       = $xml->XMLin( "xml/resources.xml",      ForceContent => 1, ForceArray => ['option'] );
my $specialist_data     = $xml->XMLin( "xml/specialists.xml",    ForceContent => 1, ForceArray => ['option'] );
my $district_data       = $xml->XMLin( "xml/districts.xml",      ForceContent => 1, ForceArray => ['option'] );

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
        $city->{'seed'} = GenericGenerator::set_seed();
    }

    generate_city_name($city);
    generate_base_stats($city);
    generate_alignment($city);
    set_city_size($city);
    set_age($city);

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

=head3 generate_base_stats()

    generate basic stats for a city.

=cut

###############################################################################
sub generate_base_stats {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 2);
    foreach my $stat ( qw( education authority magic military tolerance economy ) ){
        $city->{'stats'}->{$stat} = d(11) - 5 if ( !defined $city->{'stats'}->{$stat} );
        $city->{'stats'}->{$stat}=max(-5,min(5,$city->{'stats'}->{$stat}));
    }
    return $city;
} ## end sub generate_base_stats

###############################################################################

=head2 set_stat_descriptions

select the stat descriptions for the 6 major stats.

=cut

###############################################################################
sub set_stat_descriptions {
    #TODO merge this with base_stats like the other cool kids do.
    #This will require refactoring base_stats to use 1-100 rather that -5 - 5
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 23 );

    foreach my $stat ( sort keys %{ $city->{'stats'} } ) {
        $city->{'stats'}->{$stat} = 0 if ( !defined $city->{'stats'}->{$stat} );
        #FIXME adjectives should be an ordered array, not a random array, like govt does.
        my $statoption
            = roll_from_array( $city->{'stats'}->{$stat}, $xml_data->{ $stat . "_description" }->{'option'} );
        $city->{ $stat . "_description" } = rand_from_array( $statoption->{'option'} )->{'content'}
            if ( !defined $city->{ $stat . "_description" } );
    }

    return $city;
}



###############################################################################

=head3 generate_alignment()

    generate core alignment for the city

=cut

###############################################################################
sub generate_alignment {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 3);
    foreach my $stat ( qw( moral order ) ){
        $city->{$stat} = d(100) if ( !defined $city->{$stat} );
        $city->{$stat} = max( 1, min( 100, $city->{$stat} ) );
    }
    return $city;
} ## end sub generate_alignment


###############################################################################

=head3 set_city_size()

Find the size of the city by selecting from the citysize 
 list, then populate the size, gp limit, population, and size modifier.

=cut

###############################################################################
sub set_city_size {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 4 );
    my $citysizelist = $xml_data->{'citysize'}->{'city'};

    $city->{'size_roll'}= &d(100) if (!defined $city->{'size_roll'});

    my $citysize = roll_from_array( $city->{'size_roll'} , $citysizelist );
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

=head3 set_age()

Set the current age of the city

=cut

###############################################################################
sub set_age {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 5 );

    my $agelist = $xml_data->{'cityages'}->{'cityage'};
    $city->{'age_roll'} = d(100) + $city->{'size_modifier'} if ( !defined $city->{'age_roll'} );

    my $result = roll_from_array( $city->{'age_roll'}, $agelist );
    $city->{'age_description'} = $result->{'content'} if ( !defined $city->{'age_description'} );
    $city->{'age_mod'}         = $result->{'age_mod'} if ( !defined $city->{'age_mod'} );

    return $city;
} ## end sub set_age


###############################################################################

=head2 Secondary Methods

The following methods are used to flesh out the city.

=head3 flesh_out_city()

Add the other features beyond the core city.

=cut

###############################################################################
sub flesh_out_city {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 6 );
    $city->{'region'}    = RegionGenerator::create_region( $city->{'seed'} );
    $city->{'continent'} = ContinentGenerator::create_continent( $city->{'seed'} );

    # calculate population and race information
    set_pop_type($city);
    set_available_races($city);
    generate_race_percentages($city);
    set_races($city);
    recalculate_populations($city);
    generate_citizens($city);
    generate_children($city);
    generate_elderly($city);
    generate_imprisonment_rate($city);

    # generate basic cityscape details
    generate_resources($city);
    generate_city_crest($city);
    generate_shape($city);
    generate_streets($city);
    set_stat_descriptions($city);
    set_laws($city);

    #Generate
    generate_popdensity($city);
    generate_area($city);
    generate_walls($city);
    generate_watchtowers($city);
    generate_housing($city);
    generate_specialists($city);
    generate_businesses($city);
    generate_taverns($city);
    generate_districts($city);


    generate_travelers($city);
    generate_crime($city);
    set_dominance($city);

    $city->{'govt'}      = GovtGenerator::create_govt( {            'seed' => $city->{'seed'} } );
    $city->{'military'}  = MilitaryGenerator::create_military( {    'seed' => $city->{'seed'},  } );
    $city->{'climate'}   = ClimateGenerator::create_climate( {      'seed' => $city->{'seed'} } );
    $city->{'climate'}   = ClimateGenerator::flesh_out_climate( $city->{'climate'} );
    $city->{'astronomy'} = AstronomyGenerator::create_astronomy( { 'seed' => $city->{'seed'} } );


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
    GenericGenerator::set_seed( $city->{'seed'} + 7);
    my $citytypelist = $xml_data->{'pop_types'}->{'pop_type'};
    my $citytype = roll_from_array( &d(100), $citytypelist );
    $city->{'base_pop'}    = $citytype->{'base_pop'}  if ( !defined $city->{'base_pop'} );
    $city->{'type'}        = $citytype->{'type'}      if ( !defined $city->{'type'} );
    return $city;
} ## end sub set_pop_type


###############################################################################

=head2 set_available_races()

select the races that are available for the city's poptype.

=cut

###############################################################################
sub set_available_races {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 8 );

    if ( !defined $city->{'available_races'} ) {
        $city->{'available_races'} = [];
        foreach my $racename ( keys %{ $names_data->{'race'} } ) {
            my $race = $names_data->{'race'}->{$racename};
            if ( $race->{'type'} eq $city->{'base_pop'} or $city->{'base_pop'} eq 'mixed' ) {
                push @{ $city->{'available_races'} }, $racename;
            }
        }
    }
    shuffle @{ $city->{'available_races'} };

    return $city;
}


###############################################################################

=head2 generate_race_percentages

select the percentages used for each race.

=cut

###############################################################################
sub generate_race_percentages {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 9 );

    if ( !defined $city->{'race percentages'} ) {

        $city->{'race percentages'} = [];
        my $total_percent = 0;
        $city->{'race_limit'} = 6 if (!defined $city->{'race_limit'});
        while ( $total_percent < 98 and scalar( @{ $city->{'race percentages'} } ) <  $city->{'race_limit'} ) {

            # Of the total amount or percentage left, how much is for this race?
            my $race_percent = max( 1, int( rand() * ( 100 - $total_percent ) * 10 ) / 10 );

            # Add to percentage
            $total_percent += $race_percent;

            # Add it to our array for later usage
            push @{ $city->{'race percentages'} }, $race_percent;
        }
    }
    $city->{'race percentages'} = [ sort @{ $city->{'race percentages'} } ];
    return $city;
}


###############################################################################

=head2 set_races

set the races and percentages with the population

=cut

###############################################################################
sub set_races {
    my ($city) = @_;

    #FIXME should account for existing values
    GenericGenerator::set_seed( $city->{'seed'} + 10 );
    if ( !defined $city->{'races'} ) {
        my $totalpercent = 0;
        # ensure we save space for one "other"
        $city->{'population_total'} = 1;
        $city->{'races'}            = [];

        my @racenames = @{ $city->{'available_races'} };
        @racenames = shuffle @racenames;
        foreach my $racepercent ( sort { $b <=> $a } @{ $city->{'race percentages'} } ) {
            my $racename   = pop @racenames;
            my $population = ceil( $racepercent * $city->{'pop_estimate'} / 100 );
            my $race       = { 'race' => $racename, 'percent' => $racepercent, 'population' => $population };

            $totalpercent += $racepercent;
            $city->{'population_total'} += $population;
            push @{ $city->{'races'} }, $race;

        }
        # remove the 1 we added above
        $city->{'population_total'}--;
        my $other = {
            'race'       => 'other',
            'percent'    => max(1, 100 - $totalpercent ),
            'population' => max(1,$city->{'pop_estimate'} - $city->{'population_total'})
        };
        push @{ $city->{'races'} }, $other;
        $city->{'population_total'} += $other->{'population'};

    }

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
    GenericGenerator::set_seed( $city->{'seed'} + 11);
    foreach my $race ( @{ $city->{'races'} } ) {
        $race->{'percent'} = $race->{'population'} / $city->{'population_total'};
        $race->{'percent'} = int( $race->{'percent'} * 1000 ) / 10;
    }
    return $city;
}

###############################################################################

=head2 generate_citizens

Generate a list of citizens.

=cut

###############################################################################
sub generate_citizens {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'}  + 12);

    $city->{'citizen_count'} = 8 + floor( ($city->{'size_modifier'} + 5)*1.2) if ( !defined $city->{'citizen_count'} );
    if ( !defined $city->{'citizens'} ) {
        $city->{'citizens'} = [];
        for ( my $i = 0 ; $i < $city->{'citizen_count'} ; $i++ ) {
            push @{ $city->{'citizens'} },
                NPCGenerator::create_npc( { 'available_races' => $city->{'available_races'} } );
        }
    }
    return $city;
}


###############################################################################

=head2 generate_children

generate the number of children.

=cut

###############################################################################

sub generate_children {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 13 );

    #calculate the pop based on 20 +random factor + city age modifier; should give us a rage between
    # 10% and 45%, which follows the reported international rates of the US census bureau, so STFU.
    my $origvalue= $city->{'children'}->{'percent'} if (defined $city->{'children'}->{'percent'});
    $city->{'children'}->{'percent'} = 20 + &d(15) + ($city->{'age_mod'}||0)
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
    GenericGenerator::set_seed( $city->{'seed'} + 14 );

    #calculate the pop based on 10 +random factor - city age modifier; should give us a rage between
    # 1.5% and 26%, which follows the reported international rates of the US census bureau, so STFU.

    my $origvalue= $city->{'elderly'}->{'percent'} if (defined $city->{'elderly'}->{'percent'});
    $city->{'elderly'}->{'percent'} = max( 1.5, ( 6 + &d(5) + $city->{'age_mod'} ) )
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

    # should range from ((15-5-5-5)*.5/5+1).5/10=.05% to ((15+5+5+12)*1.5/5+1)/10=1.815
    # high authority means more in jail
    # low education means more in jail
    # larger city means more in jail
    # higher order means more in jail

    my $percent_mod = $city->{'stats'}->{'authority'} - $city->{'stats'}->{'education'} + $city->{'size_modifier'};

    my $rough_percent = ( ( ( 15 + $percent_mod ) / 5 ) + 1 ) * ( $city->{'order'} + 50 ) / 100 / 10;

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
    my $resource_count =  max( $city->{'size_modifier'} + 5 + ( $city->{'economy'} || 0 ), 5 ) ;

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
    GenericGenerator::set_seed( $city->{'seed'} + 17 );
    $city->{'crest'} = {};

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
    GenericGenerator::set_seed( $city->{'seed'} + 18 );
    $city->{'shape'} = rand_from_array( $xml_data->{'cityshape'}->{'option'} )->{'content'}
        if ( !defined $city->{'shape'} );
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

    $city->{'streets'}->{'content'} = parse_object( $xml_data->{'streets'} )->{'content'}
        if ( !defined $city->{'streets'}->{'content'} );
    my $roads = int( ( $city->{'stats'}->{'tolerance'} + $city->{'stats'}->{'economy'} ) / 3 );

    $city->{'streets'}->{'mainroads'} = $roads if ( !defined $city->{'streets'}->{'mainroads'} );
    $city->{'streets'}->{'roads'} = $roads + $city->{'streets'}->{'mainroads'}
        if ( !defined $city->{'streets'}->{'roads'} );

    $city->{'streets'}->{'mainroads'} = max( 0, $city->{'streets'}->{'mainroads'} );
    $city->{'streets'}->{'roads'}     = max( 1, $city->{'streets'}->{'roads'} );
    return $city;
}





###############################################################################

=head3 generate_walls()

Determine information about the streets. 

=cut

###############################################################################
sub generate_walls {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 20 );

    # chance of -25 to +60
    my $modifier = $city->{'size_modifier'};

    # Find a better way to determine if there's a wall.
    $city->{'wall_chance_roll'} = &d(100) - ($modifier) * 5 if ( !defined $city->{'wall_chance_roll'} );
    if ( $city->{'wall_chance_roll'} <= $xml_data->{'walls'}->{'chance'} ) {


        $city->{'walls'}->{'condition'} = roll_from_array(d(100), $xml_data->{'walls'}->{'condition'}->{'option'})->{'content'} if (!defined $city->{'walls'}->{'condition'});
        $city->{'walls'}->{'style'}     = roll_from_array(d(100), $xml_data->{'walls'}->{'style'}->{'option'})->{'content'} if (!defined $city->{'walls'}->{'style'});
        my $material                    = roll_from_array(d(100), $xml_data->{'walls'}->{'material'}->{'option'});
        $city->{'walls'}->{'material'}  = $material->{'content'} if (!defined $city->{'walls'}->{'material'});

        $city->{'walls'}->{'height'}    = int (rand( $material->{'maxheight'} - $material->{'minheight'} ) + $material->{'minheight'}  ) if (!defined  $city->{'walls'}->{'height'});



        $city->{'protected_percent'} = min( 100, 70 + d(30) + $city->{'stats'}->{'military'} )
            if ( !defined $city->{'protected_percent'} );
        $city->{'protected_area'} = sprintf( "%4.2f", ( $city->{'area'} * $city->{'protected_percent'} / 100 ) )
            if ( !defined $city->{'protected_area'} );

        my $radius = sqrt( $city->{'protected_area'} / pi );
        $city->{'walls'}->{'length'} = sprintf "%4.2f", 2 * pi * $radius * ( 100 + d(40) ) / 100;


    } else {
        $city->{'walls'}->{'height'}  = 0;
    }
    return $city;
} ## end sub generate_walls

###############################################################################

=head3 generate_watchtowers()

Determine information about the city watchtowers.

=cut

###############################################################################
sub generate_watchtowers {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 21 );

    #FIXME this shouldn't be hardcoded to 5
    $city->{'watchtowers'}->{'count'} = 5;

    return $city;
}


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

    my $stat_modifier = $city->{'stats'}->{'education'} + $city->{'stats'}->{'economy'} + $city->{'stats'}->{'magic'};
    $city->{'arable_percentage'} = max( 1, min( 100, d(100) + $stat_modifier ) )
        if ( !defined $city->{'arable_percentage'} );


    $city->{'arable_description'}
        = rand_from_array(
        roll_from_array( $city->{'arable_percentage'}, $xml_data->{'arable_description'}->{'option'} )->{'option'} )
        ->{'content'}
        if ( !defined $city->{'arable_description'} );


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
    $city->{'density_description'} = roll_from_array( $percentile, $xml_data->{'popdensity'}->{'option'} )->{'type'}
        if ( !defined $city->{'density_description'} );


    return $city;
}


###############################################################################

=head2 generate_specialists

Generate a list of specialists.

=cut

###############################################################################
sub generate_specialists {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 26);

    if ( !defined $city->{'specialists'} ) {
        $city->{'specialists'} = {};
    }

    $city->{'specialist_total'} = 0;

    foreach my $specialist_name ( sort keys %{ $specialist_data->{'option'} } ) {
        if ( !defined $city->{'specialists'}->{$specialist_name} ) {

            my $specialist = $specialist_data->{'option'}->{$specialist_name};
            if ( $specialist->{'sv'} <= $city->{'population_total'} ) {
                $city->{'specialists'}->{$specialist_name}
                    = { 'count' => floor( $city->{'population_total'} / $specialist->{'sv'} ), };
                $city->{'specialist_total'} += $city->{'specialists'}->{$specialist_name}->{'count'};
            } else {

                if ( &d( $specialist->{'sv'} ) == 1 ) {
                    $city->{'specialists'}->{$specialist_name} = { 'count' => 1 };
                    $city->{'specialist_total'} += $city->{'specialists'}->{$specialist_name}->{'count'};
                }
            }
        }
    }


    return $city;
}

###############################################################################

=head2 generate_businesses

Generate a list of businesses from existing specialists

=cut

###############################################################################


sub generate_businesses {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 27);
    if ( !defined $city->{'businesses'} ) {
        $city->{'businesses'} = {};
    }
    $city->{'business_total'} = 0;
    foreach my $specialist_name ( sort keys %{ $city->{'specialists'} } ) {
        my $specialist = $specialist_data->{'option'}->{$specialist_name};

        # Check to see if the specialist has a building associated with it.
        if ( defined $specialist->{'building'} ) {
            my $building = $specialist->{'building'};
            $city->{'businesses'}->{$building}->{'perbuilding'}
                = $specialist_data->{'option'}->{$specialist_name}->{'perbuilding'};
            $city->{'businesses'}->{$building}->{'district'}
                = $specialist_data->{'option'}->{$specialist_name}->{'district'};
            if ( defined $city->{'businesses'}->{$building}->{'specialist_count'} ) {
                $city->{'businesses'}->{$building}->{'specialist_count'}
                    += $city->{'specialists'}->{$specialist_name}->{'count'};
            } else {
                $city->{'businesses'}->{$building}->{'specialist_count'}
                    = $city->{'specialists'}->{$specialist_name}->{'count'};
            }
        }
    }

    foreach my $business_name ( keys %{ $city->{'businesses'} } ) {
        my $business = $city->{'businesses'}->{$business_name};
        $city->{'businesses'}->{$business_name}->{'count'}
            = ceil( $business->{'specialist_count'} / $business->{'perbuilding'} );
        $city->{'business_total'} += $city->{'businesses'}->{$business_name}->{'count'};
    }

    return $city;
}

###############################################################################

=head2 generate_taverns

Generate a list of taverns based on the business section

=cut

###############################################################################


sub generate_taverns {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 28);

    $city->{'taverns'} = [] if ( !defined $city->{'taverns'} );


    if ( defined $city->{'businesses'}->{'tavern'} ) {
        my $taverncount = min( 5, $city->{'businesses'}->{'tavern'}->{'count'} );
        for ( my $tavernID = 0 ; $tavernID < $taverncount ; $tavernID++ ) {
            $city->{'taverns'}->[$tavernID] = TavernGenerator::create_tavern()
                if ( !defined $city->{'taverns'}->[$tavernID] );
        }
    }
    return $city;
}
###############################################################################

=head2 generate_districts

Generate a list of districts from existing businesses

=cut

###############################################################################


sub generate_districts {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 29);

    my $district_percents = {};

    #loop through our businesses and add up modifiers for district percents
    foreach my $business_name ( keys %{ $city->{'businesses'} } ) {
        my $business      = $city->{'businesses'}->{$business_name};
        my $district_name = $business->{'district'};
        $district_percents->{$district_name}
            += ( defined $district_percents->{$district_name} ) ? &d( $business->{'count'} ) : 0;
    }

    foreach my $district_name ( keys %{ $district_data->{'option'} } ) {
        my $district = $district_data->{'option'}->{$district_name};

        my $district_modifier
            = ( defined $district_percents->{$district_name} ) ? $district_percents->{$district_name} : 0;
        my $district_roll = &d(100);

        # modify our district chance in the xml by our district_modifier
        if ( $district_roll <= $district->{'chance'} + $district_modifier + $city->{'size_modifier'} ) {
            $city->{'districts'}->{$district_name}->{'stat'}           = $district->{'stat'};
            $city->{'districts'}->{$district_name}->{'business_count'} = $district_modifier;
        }

    }
    return $city;
}
###############################################################################

=head2 generate_travelers

Generate a list of travelers.

=cut

###############################################################################
sub generate_travelers {
    my ($city) = @_;

    # NOTE adding offset of 10 to ensure travelers are not the same races as citizens...
    GenericGenerator::set_seed( $city->{'seed'} + 30 );

    $city->{'traveler_count'} = 5 + $city->{'stats'}->{'tolerance'} if ( !defined $city->{'traveler_count'} );
    if ( !defined $city->{'available_traveler_races'} ) {

        #If tolerance is negative, only city races are allowed inside.
        if ( $city->{'stats'}->{'tolerance'} < 0 ) {
            $city->{'available_traveler_races'} = $city->{'available_races'};
        } else {
            $city->{'available_traveler_races'} = [ keys %{ $names_data->{'race'} } ];
        }
    }

    if ( !defined $city->{'travelers'} ) {
        $city->{'travelers'} = [];
        for ( my $i = 0 ; $i < $city->{'traveler_count'} ; $i++ ) {
            push @{ $city->{'travelers'} },
                NPCGenerator::create_npc( { 'available_races' => $city->{'available_traveler_races'} } );
        }
    }
    return $city;
}

###############################################################################

=head2 generate_crime

Generate the crime rate

=cut

###############################################################################
sub generate_crime {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} + 31);

    my $moralmod = int( ( $city->{'moral'} - 50 ) / 10 );

    $city->{'crime_roll'}
        = min(100, max(1,int( &d(100) - $city->{'stats'}->{'education'} + $city->{'stats'}->{'authority'} + $moralmod )))
        if ( !defined $city->{'crime_roll'} );
    $city->{'crime_description'}
        = roll_from_array( $city->{'crime_roll'}, $xml_data->{'crime'}->{'option'} )->{'content'}
        if ( !defined $city->{'crime_description'} );

    return $city;
}


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
        $city->{'dominance_level'} = d(100) + $city->{'stats'}->{'authority'} - $city->{'stats'}->{'tolerance'}
            if ( !defined $city->{'dominance_level'} );
        my $dominance_option = roll_from_array( $city->{'dominance_level'}, $xml_data->{'dominance'}->{'option'} );
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
    my $economy         = $city->{'stats'}->{'economy'};

    $city->{'housing'}->{'poor_percent'} = $housing_quality->{'poor'}->{'percent'} - ( $economy * 5 )
        if ( !defined $city->{'housing'}->{'poor_percent'} );
    $city->{'housing'}->{'average_percent'} = $housing_quality->{'average'}->{'percent'} + ( $economy * 5 )
        if ( !defined $city->{'housing'}->{'average_percent'} );
    $city->{'housing'}->{'wealthy_percent'} = $housing_quality->{'wealthy'}->{'percent'}
        if ( !defined $city->{'housing'}->{'wealthy_percent'} );
    $city->{'housing'}->{'abandoned_percent'} = ( 11 - ($economy) * 2 )
        if ( !defined $city->{'housing'}->{'abandoned_percent'} );    # 1-21%


    $city->{'housing'}->{'poor_population'}
        = ceil( $city->{'population_total'} * $city->{'housing'}->{'poor_percent'} / 100 )
        if ( !defined $city->{'housing'}->{'poor_population'} );
    $city->{'housing'}->{'average_population'}
        = ceil( $city->{'population_total'} * $city->{'housing'}->{'average_percent'} / 100 )
        if ( !defined $city->{'housing'}->{'average_population'} );
    $city->{'housing'}->{'wealthy_population'}
        = ceil( $city->{'population_total'} * $city->{'housing'}->{'wealthy_percent'} / 100 )
        if ( !defined $city->{'housing'}->{'wealthy_population'} );


    $city->{'housing'}->{'poor'}
        = ceil( $city->{'housing'}->{'poor_population'} / $housing_quality->{'poor'}->{'density'} )
        if ( !defined $city->{'housing'}->{'poor'} );
    $city->{'housing'}->{'average'}
        = int( $city->{'housing'}->{'average_population'} / $housing_quality->{'average'}->{'density'} )
        if ( !defined $city->{'housing'}->{'average'} );
    $city->{'housing'}->{'wealthy'}
        = int( $city->{'housing'}->{'wealthy_population'} / $housing_quality->{'wealthy'}->{'density'} )
        if ( !defined $city->{'housing'}->{'wealthy'} );

    $city->{'housing'}->{'total'}
        = $city->{'housing'}->{'poor'} + $city->{'housing'}->{'average'} + $city->{'housing'}->{'wealthy'}
        if ( !defined $city->{'housing'}->{'total'} );
    $city->{'housing'}->{'abandoned'}
        = int( $city->{'housing'}->{'total'} * $city->{'housing'}->{'abandoned_percent'} / 100 );


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
