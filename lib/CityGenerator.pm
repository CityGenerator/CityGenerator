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
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use Math::Complex ':pi'; 
use NPCGenerator;
use RegionGenerator;
use GovtGenerator;
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
my $names_data          = $xml->XMLin( "xml/npcnames.xml",       ForceContent => 1, ForceArray => [] );
my $citynames_data      = $xml->XMLin( "xml/citynames.xml",      ForceContent => 1, ForceArray => [] );
my $regionnames_data    = $xml->XMLin( "xml/regionnames.xml",    ForceContent => 1, ForceArray => [] );
my $resource_data       = $xml->XMLin( "xml/resources.xml",      ForceContent => 1, ForceArray => [] );
my $continentnames_data = $xml->XMLin( "xml/continentnames.xml", ForceContent => 1, ForceArray => [] );
my $specialist_data     = $xml->XMLin( "xml/specialists.xml",    ForceContent => 1, ForceArray => [] );
my $district_data       = $xml->XMLin( "xml/districts.xml",      ForceContent => 1, ForceArray => [] );

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
    generate_alignment($city);
    set_city_size($city);
    set_age($city);

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
    $city->{'stats'}->{'education'} = d(11) - 5 if ( !defined $city->{'stats'}->{'education'} );
    $city->{'stats'}->{'authority'} = d(11) - 5 if ( !defined $city->{'stats'}->{'authority'} );
    $city->{'stats'}->{'magic'}     = d(11) - 5 if ( !defined $city->{'stats'}->{'magic'} );
    $city->{'stats'}->{'military'}  = d(11) - 5 if ( !defined $city->{'stats'}->{'military'} );
    $city->{'stats'}->{'tolerance'} = d(11) - 5 if ( !defined $city->{'stats'}->{'tolerance'} );
    $city->{'stats'}->{'economy'}   = d(11) - 5 if ( !defined $city->{'stats'}->{'economy'} );

    return $city;
} ## end sub generate_base_stats



###############################################################################

=head3 generate_alignment()

    generate core alignment for the city

=cut

###############################################################################
sub generate_alignment {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );
    $city->{'order'} = d(100) if ( !defined $city->{'order'} );
    $city->{'moral'} = d(100) if ( !defined $city->{'moral'} );

    $city->{'order'} =min(100,max(0,$city->{'order'}));
    $city->{'moral'} =min(100,max(0,$city->{'moral'}));

    return $city;
} ## end sub generate_alignment



###############################################################################

=head3 generate_city_name()

    generate a name for the city.

=cut

###############################################################################
sub generate_city_name {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );
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
    GenericGenerator::set_seed( $city->{'seed'} );
    my $citysizelist = $xml_data->{'citysize'}->{'city'};

    my $citysize = roll_from_array( &d(100), $citysizelist );
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
    GenericGenerator::set_seed( $city->{'seed'} );
    $city->{'region'}    = RegionGenerator::create_region( $city->{'seed'} );
    $city->{'continent'} = ContinentGenerator::create_continent( $city->{'seed'} );

    # calculate population and race information
    set_pop_type($city);
    set_available_races($city);
    generate_race_percentages($city);
    set_races($city);
    assign_race_stats($city);
    recalculate_populations($city);
    generate_citizens($city);
    generate_children($city);
    generate_elderly($city);
    generate_imprisonment_rate($city);

    # generate basic cityscape details
    generate_resources($city);
    generate_city_crest($city);
    generate_shape($city);
    generate_city_age($city);
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
    generate_districts($city);


    generate_travelers($city);
    generate_crime($city);
    set_dominance($city);

    $city->{'govt'}=GovtGenerator::create_govt( {'seed'=>$city->{'seed'}});
    $city->{'climate'}=ClimateGenerator::create_climate({'seed'=>$city->{'seed'}});
    $city->{'climate'}=ClimateGenerator::flesh_out_climate(  $city->{'climate'} );
    $city->{'astronomy'}=AstronomyGenerator::create_astronomy( {'seed'=>$city->{'seed'} }  );
    

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
    GenericGenerator::set_seed( $city->{'seed'} );
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
    GenericGenerator::set_seed( $city->{'seed'} );

    # chance of -25 to +60
    my $modifier = $city->{'size_modifier'} || 0;

    $city->{'wall_chance_roll'} = &d(100) - ($modifier) * 5 if (!defined $city->{'wall_chance_roll'});

    if ( $city->{'wall_chance_roll'} <= $xml_data->{'walls'}->{'chance'} ) {
        $city->{'wall_size_roll'} = &d(100) + $modifier if (!defined $city->{'wall_size_roll'});
        my $wall = roll_from_array( $city->{'wall_size_roll'}, $xml_data->{'walls'}->{'wall'} );
        $city->{'walls'} = parse_object($wall);
        $city->{'walls'}->{'height'} = $wall->{'heightmin'} + &d( $wall->{'heightmax'} - $wall->{'heightmin'} ) + $modifier;

        $city->{'protected_percent'} = min(100,   70+d(30) + $city->{'stats'}->{'military'}  )  if (!defined $city->{'protected_percent'});
        $city->{'protected_area'} = sprintf("%4.2f", ( $city->{'area'} *  $city->{'protected_percent'} /100)) if (!defined $city->{'protected_area'} );

        my $radius= sqrt($city->{'protected_area'} / pi);
        $city->{'walls'}->{'length'}= sprintf  "%4.2f",  2* pi * $radius *(100 + d(40))/100  ; 


    } else {
        $city->{'walls'}->{'content'} = "none";
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
    GenericGenerator::set_seed( $city->{'seed'} );
    #FIXME this shouldn't be hardcoded to 5
    $city->{'watchtowers'}->{'count'}=5;

    return $city;
}


###############################################################################

=head3 set_laws()

Set the laws for the city.

=cut

###############################################################################

sub set_laws {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );

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
    GenericGenerator::set_seed( $city->{'seed'} );

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

    GenericGenerator::set_seed( $city->{'seed'} );

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
    GenericGenerator::set_seed( $city->{'seed'} );
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
    GenericGenerator::set_seed( $city->{'seed'} );
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
    GenericGenerator::set_seed( $city->{'seed'} );

    $city->{'city_age'}= rand_from_array(   $xml_data->{'cityages'}->{'cityage'}  ) if (!defined  $city->{'city_age'});
    return $city;
}


###############################################################################

=head2 set_available_races()

select the races that are available for the city's poptype.

=cut

###############################################################################
sub set_available_races {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );
    #FIXME TODO finish this.

    if (! defined $city->{'available_races'} ){
        $city->{'available_races'}=[];
        foreach my $racename ( keys %{ $names_data->{'race'} }  ){
            my $race=$names_data->{'race'}->{$racename}; 
            if ($race->{'type'} eq $city->{'base_pop'}  or $city->{'base_pop'} eq 'mixed'){
                push @{$city->{'available_races'}}, $racename;
            }
        }
    }
    shuffle @{$city->{'available_races'}};

    return $city;
}


###############################################################################

=head2 generate_race_percentages

select the percentages used for each race.

=cut

###############################################################################
sub generate_race_percentages {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );
    #FIXME TODO finish this.

    if (! defined $city->{'race percentages'} ){

        $city->{'race percentages'}=[];
        my $total_percent=0;
        my $race_limit=6;
        while ( $total_percent < 98 and scalar(@{$city->{'race percentages'}}) < $race_limit ){
 
            # Of the total amount or percentage left, how much is for this race?
            my $race_percent= max( 1, int( rand()*(100-$total_percent)*10)/10);
 
            # Add to percentage
            $total_percent +=$race_percent;
 
            # Add it to our array for later usage
            push @{$city->{'race percentages'}}, $race_percent;
        }
    }
    $city->{'race percentages'} = [ sort @{$city->{'race percentages'}}];
    return $city;
}

###############################################################################

=head2 set_stat_descriptions

select the stat descriptions for the 6 major stats.

=cut

###############################################################################
sub set_stat_descriptions {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );

    foreach my $stat (sort keys %{ $city->{'stats'} } ){
        $city->{'stats'}->{$stat}=0 if (! defined $city->{'stats'}->{$stat});
        my $statoption =roll_from_array( $city->{'stats'}->{$stat}, $xml_data->{$stat."_description"}->{'option'});
        $city->{$stat."_description"}=rand_from_array($statoption->{'option'} )->{'content'} if (!defined $city->{$stat."_description"});
    }

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
    GenericGenerator::set_seed( $city->{'seed'} );
    if (! defined $city->{'races'} ){
        my $totalpercent=0;
        $city->{'population_total'}=0;
        $city->{'races'}=[];
        my @racenames= @{$city->{'available_races'}}  ;
        @racenames=shuffle @racenames;
        foreach my $racepercent ( sort {$b <=> $a} @{ $city->{'race percentages'} } ){
            my $racename= pop @racenames;
            my $population=int($racepercent*$city->{'pop_estimate'}/100) ;
            my $race={'race'=>$racename, 'percent'=>$racepercent, 'population'=>$population };

            $totalpercent+=$racepercent;
            $city->{'population_total'}+=$population;
            push @{$city->{'races'}}, $race;

        }
        my $other={'race'=>'other', 'percent'=>(100-$totalpercent), 'population'=>($city->{'pop_estimate'}-$city->{'population_total'}   ) };
        push @{$city->{'races'}}, $other;
        $city->{'population_total'}+=$other->{'population'};

    }

    return $city;
}

###############################################################################

=head2 assign_race_stats

assign the racial stats to the race objects and update the city stats

=cut

###############################################################################
sub assign_race_stats {
#TODO needs to account for existing values
    my ($city) = @_;
    my @newracelist;
    GenericGenerator::set_seed( $city->{'seed'} );

    foreach my $race (@{$city->{'races'}}){
        my $racename=$race->{'race'};
        my $racestats=$names_data->{'race'}->{$racename};
        foreach my $stat (qw/ plural article type / ){
            $race->{$stat}=$racestats->{$stat};
        }
        foreach my $stat (qw/ magic economy authority education military tolerance / ){
            $race->{$stat}=$racestats->{$stat};
            $city->{'stats'}->{$stat}+=$racestats->{$stat};
        }
        foreach my $stat (qw/ moral order / ){
            $race->{$stat}=$racestats->{$stat};
            $city->{$stat}+=$racestats->{$stat};
        }
        push @newracelist, $race;
    }
    $city->{'races'}=\@newracelist;
    foreach my $stat (qw/ magic economy authority education military tolerance / ){
        $city->{'stats'}->{$stat}=  min(5, max(-5,$city->{'stats'}->{$stat})) ;
    }
    foreach my $stat (qw/ moral order / ){
            $city->{$stat} =min(100,max(0,$city->{$stat}));
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
    GenericGenerator::set_seed( $city->{'seed'} );
    foreach my $race (@{$city->{'races'}}){
        $race->{'percent'}= $race->{'population'}/ $city->{'population_total'} ;
        $race->{'percent'}=  int( $race->{'percent'}*1000 )/10
    }
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
    GenericGenerator::set_seed( $city->{'seed'} );

    $city->{'streets'}->{'content'}=parse_object($xml_data->{'streets'})->{'content'} if  (!defined $city->{'streets'}->{'content'} );
    my $roads=int(($city->{'stats'}->{'tolerance'}+$city->{'stats'}->{'economy'})/3);

    $city->{'streets'}->{'mainroads'}   = $roads                                        if  (!defined $city->{'streets'}->{'mainroads'} );
    $city->{'streets'}->{'roads'}       = $roads + $city->{'streets'}->{'mainroads'}    if  (!defined $city->{'streets'}->{'roads'} );

    $city->{'streets'}->{'mainroads'}   = max(0, $city->{'streets'}->{'mainroads'});
    $city->{'streets'}->{'roads'}       = max(1, $city->{'streets'}->{'roads'} );
    return $city;
}

###############################################################################

=head2 generate_area

Generate the area the city covers.

=cut

###############################################################################
sub generate_area {
#TODO change to metric....
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );
    $city->{'area'}=sprintf "%4.2f",    $city->{'population_total'} / $city->{'population_density'};

    my $stat_modifier=$city->{'stats'}->{'education'}+$city->{'stats'}->{'economy'}+$city->{'stats'}->{'magic'};
    $city->{'arable_percentage'}= max(1,min(100 ,d(100) + $stat_modifier ))  if (!defined $city->{'arable_percentage'});



    $city->{'arable_description'}=
                                rand_from_array(
                                        roll_from_array($city->{'arable_percentage'} , $xml_data->{'arable_description'}->{'option'} )->{'option'}
                              )->{'content'} if (!defined $city->{'arable_description'});



    return $city;
}


###############################################################################

=head2 generate_popdensity

Generate the density of the population, given the base city size. Units are people per sq km.
=cut

###############################################################################
sub generate_popdensity {
# TODO addmagic, economey, etc to impact density
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );
    my $range = $city->{'max_density'} - $city->{'min_density'} ;
    my $delta = &d(  $range  );
    $city->{'population_density'}= $city->{'min_density'} + $delta  if (!defined $city->{'population_density'});

    my $percentile= ($city->{'population_density'} - $city->{'min_density'}  )/$range*100    ;
    $city->{'density_description'}= roll_from_array( $percentile, $xml_data->{'popdensity'}->{'option'})->{'type'} if (!defined $city->{'density_description'});


    return $city;
}

###############################################################################

=head2 generate_citizens

Generate a list of citizens.

=cut

###############################################################################
sub generate_citizens {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );

    $city->{'citizen_count'}= 7 + int($city->{'size_modifier'}/2) if (!defined $city->{'citizen_count'});
    if (!defined $city->{'citizens'}){
        $city->{'citizens'}= [];
        for (my $i=0 ; $i<$city->{'citizen_count'} ; $i++){
            push @{$city->{'citizens'}},NPCGenerator::create_npc({'available_races'=>$city->{'available_races'}}); 
        }
    }
    return $city;
}


###############################################################################

=head2 generate_specialists

Generate a list of specialists.

=cut

###############################################################################
sub generate_specialists {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );

    if (!defined $city->{'specialists'}){
        $city->{'specialists'}={};
    }

    $city->{'specialist_total'}=0;

    foreach my $specialist_name (sort keys %{$specialist_data->{'option'}}){
        if (! defined $city->{'specialists'}->{$specialist_name}){

            my $specialist=$specialist_data->{'option'}->{$specialist_name};
            if ($specialist->{'sv'} <= $city->{'population_total'}  ){
                $city->{'specialists'}->{$specialist_name}={
                    'count'=>floor($city->{'population_total'}/$specialist->{'sv'} ),
                };
                $city->{'specialist_total'}+=$city->{'specialists'}->{$specialist_name}->{'count'};
            }else{
                 
                if (&d($specialist->{'sv'}) == 1 ){
                    $city->{'specialists'}->{$specialist_name}={ 'count'=>1 };
                    $city->{'specialist_total'}+=$city->{'specialists'}->{$specialist_name}->{'count'};
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
    GenericGenerator::set_seed( $city->{'seed'} );
    if (!defined $city->{'businesses'}){
        $city->{'businesses'}={};
    }
    $city->{'business_total'}=0;
    foreach my $specialist_name (sort keys %{$city->{'specialists'}}){
        my $specialist=$specialist_data->{'option'}->{$specialist_name};

        # Check to see if the specialist has a building associated with it.
        if (defined $specialist->{'building'}){
            my $building = $specialist->{'building'};
            $city->{'businesses'}->{$building}->{'perbuilding'}= $specialist_data->{'option'}->{$specialist_name}->{'perbuilding'};
            $city->{'businesses'}->{$building}->{'district'}= $specialist_data->{'option'}->{$specialist_name}->{'district'};
            if (defined $city->{'businesses'}->{$building}->{'specialist_count'}){
                $city->{'businesses'}->{$building}->{'specialist_count'}+= $city->{'specialists'}->{$specialist_name}->{'count'} ;
            }else{
                $city->{'businesses'}->{$building}->{'specialist_count'}= $city->{'specialists'}->{$specialist_name}->{'count'} ;
            }
        }
    }

    foreach my $business_name (keys %{$city->{'businesses'}} ){
        my $business=$city->{'businesses'}->{$business_name};
        $city->{'businesses'}->{$business_name}->{'count'} = ceil( $business->{'specialist_count'}/ $business->{'perbuilding'} );
        $city->{'business_total'}+= $city->{'businesses'}->{$business_name}->{'count'};
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
    GenericGenerator::set_seed( $city->{'seed'} );

    my $district_percents={};
    #loop through our businesses and add up modifiers for district percents
    foreach my $business_name (keys %{$city->{'businesses'}} ){
        my $business= $city->{'businesses'}->{$business_name};
        my $district_name= $business->{'district'} ;
        $district_percents->{$district_name} +=    (defined $district_percents->{$district_name}) ?  &d( $business->{'count'}) : 0 ;
    }

    foreach my $district_name (keys %{$district_data->{'option'}} ){
        my $district=$district_data->{'option'}->{$district_name};
        
        my $district_modifier=  (defined $district_percents->{$district_name}) ? $district_percents->{$district_name} : 0;
        my $district_roll=&d(100);
        # modify our district chance in the xml by our district_modifier
        if ($district_roll <= $district->{'chance'} + $district_modifier + $city->{'size_modifier'}){
            $city->{'districts'}->{$district_name}->{'stat'}= $district->{'stat'};
            $city->{'districts'}->{$district_name}->{'business_count'}= $district_modifier ;
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
    GenericGenerator::set_seed( $city->{'seed'} + 10 );

    $city->{'traveler_count'}= 5 + $city->{'stats'}->{'tolerance'} if (!defined $city->{'traveler_count'});
    if (!defined $city->{'available_traveler_races'}){
        #If tolerance is negative, only city races are allowed inside.
        if ($city->{'stats'}->{'tolerance'} <0){
            $city->{'available_traveler_races'}= $city->{'available_races'};
        }else{
            $city->{'available_traveler_races'}= [keys %{ $names_data->{'race'} } ];
        }
    }

    if (!defined $city->{'travelers'}){
        $city->{'travelers'}= [];
        for (my $i=0 ; $i<$city->{'traveler_count'} ; $i++){
            push @{$city->{'travelers'}},NPCGenerator::create_npc({'available_races'=>$city->{'available_traveler_races'}} ); 
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
    GenericGenerator::set_seed( $city->{'seed'} );

    my $moralmod=int( ($city->{'moral'} - 50 ) /10);

    $city->{'crime_roll'} = int(&d(100) - $city->{'stats'}->{'education'} + $city->{'stats'}->{'authority'} + $moralmod)    if (!defined $city->{'crime_roll'});
    $city->{'crime_description'}=roll_from_array($city->{'crime_roll'}, $xml_data->{'crime'}->{'option'})->{'content'}      if (!defined $city->{'crime_description'});

    return $city;
}


###############################################################################

=head2 set_dominance

select a race to be dominant, as well as the level of dominance.

=cut

###############################################################################
sub set_dominance {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );

    $city->{'dominance_chance'}=d(100) if (!defined $city->{'dominance_chance'} );
    if ( $city->{'dominance_chance'}   <   $xml_data->{'dominance'}->{'chance'}){
        $city->{'dominant_race'}=rand_from_array($city->{'races'})->{'race'} if (!defined $city->{'dominant_race'} );
        $city->{'dominance_level'}=d(100)+$city->{'stats'}->{'authority'}-$city->{'stats'}->{'tolerance'} if (!defined $city->{'dominance_level'} );
        my $dominance_option=roll_from_array( $city->{'dominance_level'},  $xml_data->{'dominance'}->{'option'}  );
        $city->{'dominance_description'}=$dominance_option->{'content'}  if (!defined $city->{'dominance_description'} );
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
    GenericGenerator::set_seed( $city->{'seed'} );

    #calculate the pop based on 20 +random factor + city age modifier; should give us a rage between
    # 10% and 45%, which follows the reported international rates of the US census bureau, so STFU.
    $city->{'children'}->{'percent'} = 20 + &d(15) + $city->{'age_mod'} if  (!defined $city->{'children'}->{'percent'});
#FIXME the agemod should skew the other way!!!
    #calculate out the actual child population in whole numbers
    $city->{'children'}->{'population'}= int(  $city->{'children'}->{'percent'} / 100 * $city->{'population_total'}) if (!defined $city->{'children'}->{'population'} );

    #recalulate to make the percent accurate with the population
    $city->{'children'}->{'percent'}=sprintf "%0.2f", $city->{'children'}->{'population'}/$city->{'population_total'}*100 ;


    return $city;
}

###############################################################################

=head2 generate_elderly

generate the number of elderly.

=cut

###############################################################################

sub generate_elderly {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );
    #calculate the pop based on 10 +random factor - city age modifier; should give us a rage between
    # 1.5% and 26%, which follows the reported international rates of the US census bureau, so STFU.

    $city->{'elderly'}->{'percent'} = max(1.5, (6 + &d(5) + $city->{'age_mod'}))   if ( ! defined $city->{'elderly'}->{'percent'});

    #calculate out the actual child population in whole numbers
    $city->{'elderly'}->{'population'}= int(  $city->{'elderly'}->{'percent'} / 100 * $city->{'population_total'}) if (!defined $city->{'elderly'}->{'population'} );

    #recalulate to make the percent accurate with the population
    $city->{'elderly'}->{'percent'}=sprintf "%0.2f", $city->{'elderly'}->{'population'}/$city->{'population_total'}*100 ;


    return $city;
}

###############################################################################

=head2 generate_imprisonment_rate

generate the number of imprisonment_rate.

=cut

###############################################################################

sub generate_imprisonment_rate {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );
    # should range from ((15-5-5-5)*.5/5+1).5/10=.05% to ((15+5+5+12)*1.5/5+1)/10=1.815
    # high authority means more in jail
    # low education means more in jail
    # larger city means more in jail
    # higher order means more in jail

    my $percent_mod=$city->{'stats'}->{'authority'} - $city->{'stats'}->{'education'}  + $city->{'size_modifier'} ;

    my $rough_percent = (((15 + $percent_mod )/5) +1 )*($city->{'order'}+50)/100 /10 ;

    #calculate out the actual child population in whole numbers
    $city->{'imprisonment_rate'}->{'population'}= int(  $rough_percent / 100 * $city->{'population_total'}) if (!defined $city->{'imprisonment_rate'}->{'population'} );

    #recalulate to make the percent accurate with the population
    $city->{'imprisonment_rate'}->{'percent'}=sprintf "%0.2f", $city->{'imprisonment_rate'}->{'population'}/$city->{'population_total'}*100 if (!defined  $city->{'imprisonment_rate'}->{'percent'});

    return $city;
}

###############################################################################

=head2 generate_housing

generate the number of houses for the population

=cut

###############################################################################

sub generate_housing {
    my ($city) = @_;
    GenericGenerator::set_seed( $city->{'seed'} );

    my $housing_quality=$xml_data->{'housing'}->{'quality'};
    my $economy=$city->{'stats'}->{'economy'};

    $city->{'housing'}->{'poor_percent'}   =$housing_quality->{'poor'}->{'percent'}    - ($economy*5) if (!defined $city->{'housing'}->{'poor_percent'});
    $city->{'housing'}->{'average_percent'}=$housing_quality->{'average'}->{'percent'} + ($economy*5) if (!defined $city->{'housing'}->{'average_percent'});
    $city->{'housing'}->{'wealthy_percent'}=$housing_quality->{'wealthy'}->{'percent'}                if (!defined $city->{'housing'}->{'wealthy_percent'});
    $city->{'housing'}->{'abandoned_percent'} = (11-($economy)*2 )                                    if (!defined $city->{'housing'}->{'abandoned_percent'}); # 1-21%


    $city->{'housing'}->{'poor_population'}     = ceil($city->{'population_total'} * $city->{'housing'}->{'poor_percent'}/100)    if (!defined $city->{'housing'}->{'poor_population'});
    $city->{'housing'}->{'average_population'}  = ceil($city->{'population_total'} * $city->{'housing'}->{'average_percent'}/100) if (!defined $city->{'housing'}->{'average_population'});
    $city->{'housing'}->{'wealthy_population'}  = ceil($city->{'population_total'} * $city->{'housing'}->{'wealthy_percent'}/100) if (!defined $city->{'housing'}->{'wealthy_population'});


    $city->{'housing'}->{'poor'}     = ceil($city->{'housing'}->{'poor_population'}    / $housing_quality->{'poor'}->{'density'})    if (!defined $city->{'housing'}->{'poor'});
    $city->{'housing'}->{'average'}  =  int($city->{'housing'}->{'average_population'} / $housing_quality->{'average'}->{'density'}) if (!defined $city->{'housing'}->{'average'});
    $city->{'housing'}->{'wealthy'}  =  int($city->{'housing'}->{'wealthy_population'} / $housing_quality->{'wealthy'}->{'density'}) if (!defined $city->{'housing'}->{'wealthy'});

    $city->{'housing'}->{'total'} = $city->{'housing'}->{'poor'} + $city->{'housing'}->{'average'} + $city->{'housing'}->{'wealthy'} if (!defined $city->{'housing'}->{'total'});
    $city->{'housing'}->{'abandoned'} = int( $city->{'housing'}->{'total'} * $city->{'housing'}->{'abandoned_percent'}/100 );


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
