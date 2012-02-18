#!/usr/bin/perl -w
####################################################################
#                     City Generation Script                       #
# Author: Jesse Morgan                                             #
# Purpose: Generate a random city and the conditions               #
####################################################################
use strict;
use Data::Dumper;
use XML::Simple;
use List::Util 'shuffle';
use POSIX;


my $xml = new XML::Simple;
our $xml_data = $xml->XMLin( "data.xml", ForceContent => 1, ForceArray => [] );


my $city = build_city();

print Dumper $city;


exit;

####################################################################
####################################################################
####################################################################
####################################################################


sub build_city {
    my $city;

#Steps for generating a random city

# - Generate a size
    $city = set_city_size($city);
# - Generate a type
    $city = set_city_type($city);
# - Generate a name
    $city = generate_city_name($city);
# - Generate a pop_type
    $city = generate_pop_type($city);
# - Generate pop counts
    $city = generate_pop_counts($city);
# - Generate assign races
    $city = assign_races($city);
# - Generate ethics
    $city = generate_city_ethics($city);
# - generate gov't type
    $city = set_govt_type($city);
# - generate location
    $city = set_location($city);
# - generate weather
    $city = set_weather($city);
# - generate time
    $city = set_time($city);
# - generate laws
    $city = set_laws($city);
# - generate events
    $city = generate_events($city);
# - generate blackmarkets
    $city = generate_markets($city);

#taverns
# - generate religions(weighted by race)
# - generate street condition
# - generate natural resources
# - generate map
    return $city;
} ## end sub build_city

sub generate_markets {
    my ($city) = @_;
    my @markets;
    for my $market (@{ $xml_data->{'markets'}->{'option'} } ){
        if (&d(100) < $market->{'chance'}){
            my $newmarket->{'type'}=$market->{'type'};
            $newmarket->{'name'}=$market->{'marketname'}.' '.$market->{'type'};
            if ( &d(100) <$market->{'secret'} ){
                $newmarket->{'secret'}='true';
            }else{
                $newmarket->{'secret'}='false';
            }
            if ( &d(100) > 50 ){
                $newmarket->{'name'}= rand_from_array(@{$market->{'option'}})->{'content'}.' '.$newmarket->{'name'};
            }
            push @markets, $newmarket;
        }
    }
    $city->{'markets'}=\@markets;
    return $city;
}

sub generate_events {
    my ($city) = @_;
    my $event_chance=$xml_data->{'events'}->{'chance'};
    my $limit=$xml_data->{'events'}->{'limit'};
    $city->{'events'}=[];
    my @events;

    for my $event (shuffle @{ $xml_data->{'events'}->{'event'} } ){
        if ($limit > 0 and &d(100) < $event_chance ){
            my $eventname=$event->{'type'};
            my $desc = rand_from_array( @{ $event->{'option'} } )->{'content'};
            push @{$city->{'events'}}, $desc.$eventname;
            $limit--;
        }
    }

    return $city;
} ## end sub set_weather

sub set_weather {
    my ($city) = @_;
    $city->{'weather'} = {};
    if ( $city->{'location'} ne 'Underground' ) {

        $city = set_forecast($city);

        $city = set_clouds($city);

        $city = set_precip($city);

        $city = set_thunder($city);

    } ## end if ( $city->{'location'...})
    for my $facet (qw( temp air wind)) {
        $city->{'weather'}->{$facet}
            = rand_from_array( @{ $xml_data->{'weather'}->{$facet}->{'option'} } )->{'content'};
    }
    return $city;
} ## end sub set_weather

sub set_forecast {
    my ($city) = @_;
    my @forecasttypes = @{ $xml_data->{'weather'}->{'forecast'}->{'option'} };
    $city->{'weather'}->{'forecast'} = rand_from_array(@forecasttypes)->{'content'};
    return $city;
} ## end sub set_forecast

sub set_clouds {
    my ($city) = @_;
    my @cloudtypes = @{ $xml_data->{'weather'}->{'clouds'}->{'option'} };
    $city->{'weather'}->{'clouds'} = rand_from_array(@cloudtypes)->{'content'};
    return $city;
} ## end sub set_clouds

sub set_thunder {
    my ($city) = @_;
    if ( &d(100) < $xml_data->{'weather'}->{'thunder'}->{'chance'} ) {
        my @thundertypes = @{ $xml_data->{'weather'}->{'thunder'}->{'option'} };
        $city->{'weather'}->{'thunder'} = rand_from_array(@thundertypes)->{'content'};
    }
    return $city;
} ## end sub set_thunder

sub set_precip {
    my ($city) = @_;
    if ( &d(100) < $xml_data->{'weather'}->{'precip'}->{'chance'} ) {
        my $precip = rand_from_array( @{ $xml_data->{'weather'}->{'precip'}->{'option'} } );
        if ( defined $precip->{'type'} ) {
            $city->{'weather'}->{'precip'} = rand_from_array( @{ $precip->{'type'} } )->{'content'};
        }
        $city->{'weather'}->{'precip'} .= $precip->{'description'};
    } ## end if ( &d(100) < $xml_data...)
    return $city;
} ## end sub set_precip

sub set_laws {
    my ($city) = @_;
    $city->{'laws'} = {};
    for my $facet (qw( enforcement trial punishment)) {
        $city->{'laws'}->{$facet} = rand_from_array( @{ $xml_data->{'laws'}->{$facet}->{'option'} } )->{'content'};
    }
    return $city;
} ## end sub set_laws

sub set_time {
    my ($city) = @_;
    my $roll   = &d(100);
    my $time   = rand_from_array( @{ $xml_data->{'time'}->{'option'} } );
    $city->{'time'} = $time;
    return $city;
} ## end sub set_time

sub set_location {
    my ($city) = @_;
    my $location = rand_from_array( @{ $xml_data->{'locations'}->{'location'} } );
    $city->{'location'}  = $location->{'description'};
    $city->{'landmarks'} = set_landmarks($location);
    return $city;
} ## end sub set_location

sub set_landmarks {
    my ($location) = @_;
    my @landmarks;
    foreach my $landmark ( @{ $location->{landmarks} } ) {
        if ( &d(100) < $landmark->{'chance'} ) {
            push @landmarks, $landmark->{'content'};
        }
    }
    return \@landmarks;
} ## end sub set_landmarks
sub rand_from_array {
    my (@array) = @_;
    my $index = int( rand( scalar @array ) );
    return $array[$index];
}


sub set_govt_type {
    my ($city) = @_;
    $city->{'govtype'} = rand_from_array( @{ $xml_data->{'govtypes'}->{'govt'} } );
    return $city;
}

sub assign_races {
    my ($city)          = @_;
    my $base_pop        = $city->{'base_pop'};
    my @available_races = get_races($base_pop);

    my @races;

    for my $race ( @{ $city->{'races'} } ) {
        my $newrace = pop(@available_races);
        $race = add_race_features( $race, $newrace );
        push @races, $race;
    }

    if ( $city->{'add_other'} eq 'true' ) {
        my $newrace      = get_other_race($base_pop);
        my $replace_race = &d( scalar @races ) - 1;
        $races[$replace_race] = add_race_features( $races[$replace_race], $newrace );
    }

    $city->{'races'} = \@races;

    return $city;
} ## end sub assign_races

sub add_race_features {
    my ( $race, $newrace ) = @_;
    $race->{'name'}      = $newrace->{'content'};
    $race->{'order_mod'} = $newrace->{'order_mod'};
    $race->{'moral_mod'} = $newrace->{'moral_mod'};
    $race->{'magic_mod'} = $newrace->{'magic_mod'};
    $race->{'type'}      = $newrace->{'type'};
    return $race;
} ## end sub add_race_features


sub get_other_race {
    my ($type) = @_;
    my @races;
    for my $race ( shuffle @{ $xml_data->{'races'}->{'race'} } ) {
        if ( $race->{'type'} ne $type ) {
            return $race;
        }
    }
} ## end sub get_other_race

sub get_races {
    my ( $type, ) = @_;
    my @races;
    for my $race ( @{ $xml_data->{'races'}->{'race'} } ) {
        if ( $race->{'type'} eq $type or $type eq 'mixed' ) {
            push @races, $race;
        }
    }
    return shuffle @races;
} ## end sub get_races

sub generate_pop_counts {
    my ($city)     = @_;
    my $roll       = &d(100);
    my $population = $city->{'population'};
    my $newpop     = 0;
    my @races;
    for my $race ( reverse @{ $city->{'races'} } ) {
        $race->{'count'} = ceil( $population * $race->{'percent'} / 100 );
        $newpop += $race->{'count'};
        push @races, $race;
    }
    $city->{'population'} = $newpop;
    $city->{'races'}      = \@races;
    my @newraces;
    for my $race ( @{ $city->{'races'} } ) {
        $race->{'percent'} = int( $race->{'count'} / $newpop * 1000 ) / 10;
        push @newraces, $race;
    }
    $city->{'races'} = \@newraces;
    return $city;
} ## end sub generate_pop_counts

sub generate_pop_type {
    my ($city) = @_;
    my $roll = &d(100);
    my $poptype = roll_from_array( $roll, $xml_data->{'poptypes'}->{'population'} );
    $city->{'poptype'} = $poptype->{'type'};
    $city->{'races'}   = $poptype->{'option'};
    return $city;
} ## end sub generate_pop_type

sub generate_city_ethics {
    my ($city) = @_;
    $city->{'moral'} = &d(100);
    $city->{'order'} = &d(100);
    $city->{'magic'} = &d(100);
    for my $race ( @{ $city->{'races'} } ) {
        $city->{'moral'} += $race->{'moral_mod'};
        $city->{'order'} += $race->{'order_mod'};
        $city->{'magic'} += $race->{'magic_mod'};
    }
    if ( $city->{'moral'} < 1 )   { $city->{'moral'} = 1; }
    if ( $city->{'moral'} > 100 ) { $city->{'moral'} = 100; }
    if ( $city->{'order'} < 1 )   { $city->{'order'} = 1; }
    if ( $city->{'order'} > 100 ) { $city->{'order'} = 100; }
    if ( $city->{'magic'} < 1 )   { $city->{'magic'} = 1; }
    if ( $city->{'magic'} > 100 ) { $city->{'magic'} = 100; }
    return $city;
} ## end sub generate_city_ethics


sub set_city_size {
    my ($city) = @_;
    my $roll = &d(100);
    my $citysize = roll_from_array( $roll, $xml_data->{'citysize'}->{'city'} );
    $city->{'size'}          = $citysize->{'size'};
    $city->{'gplimit'}       = $citysize->{'gplimit'};
    $city->{'population'}    = $citysize->{'minpop'} + &d( $citysize->{'maxpop'} - $citysize->{'minpop'} );
    $city->{'size_modifier'} = $citysize->{'size_modifier'};

    return $city;
} ## end sub set_city_size

sub set_city_type {
    my ($city) = @_;
    my $roll = &d(100);
    my $citytype = roll_from_array( $roll, $xml_data->{'citytype'}->{'city'} );
    $city->{'base_pop'}    = $citytype->{'base_pop'};
    $city->{'type'}        = $citytype->{'type'};
    $city->{'description'} = $citytype->{'content'};
    $city->{'add_other'}   = $citytype->{'add_other'};
    return $city;
} ## end sub set_city_type

#####################################
# Generate a City Name
# There is the prefix, the root, the suffix and the trailer
sub generate_city_name {
    my ($city) = @_;
    my $cityname;
    for my $partname (qw( prefix root suffix trailer )) {
        my $part = $xml_data->{$partname};

        # If no chance is set, or d100 is greater than the chance, add the part.
        if ( !defined $part->{'chance'} or $part->{'chance'} > &d(100) ) {
            my @words     = @{ $part->{'word'} };
            my $wordcount = scalar(@words);

            $cityname .= @words[ &d($wordcount) ]->{'content'};
        } ## end if ( !defined $part->{...})
    } ## end for my $partname (qw( prefix root suffix trailer ))
    $city->{'name'} = $cityname;
    return $city;
} ## end sub generate_city_name
#######################################################
# Presuming $items is an array of xml object with
# a min and max property, select the one that $roll
# best fits.
sub roll_from_array {
    my ( $roll, $items ) = @_;
    my $selected_item = $items->[0];
    for my $item (@$items) {
        if ( $item->{'min'} <= $roll and $item->{'max'} >= $roll ) {
            $selected_item = $item;
            last;
        }
    } ## end for my $item (@$items)
    return $selected_item;
} ## end sub roll_from_array

sub d {

#    d as in 1d6
    my ($die) = @_;
    return int( rand($die) );
} ## end sub d


####################################################################
####################################################################

#Still Garbage
############################################
##  Work out the pretty formatting for the
##  output
#
#print "\n\n\t=========  ".$city->{'name'}."  =========\n";
#print Dumper($city);
#print "\n\t".$city->{'name'}." is ". &determine_city_type($city_type)." ".$city->{'type'}." with a population of around $population.\n";
#print "\tThe ".$city->{'type'}." population is ".$poptype->{'type'}.", with the following breakdown:\n";
#for my $percentage (@{$pop_breakdown->{'percentage'}}){
#    print "\t\t".int(($percentage->{'content'}/100)*$population+1)."\t(".$percentage->{'content'}."%)\t".$percentage->{'race'}->{'content'}."\n";
#}
#print "\tMorals:\n";
#print "\tThe city is ruled by a ";
#if (&order_type($city->{'order'}) eq &moral_type($city->{'moral'})){
#    print "true neutral";
#}else{
#    print &order_type($city->{'order'})." ".&moral_type($city->{'moral'});
#}
#print " ".$city->{'govtype'}." (".$city->{'order'}.",".$city->{'moral'}.").\n";
#
#print "\n\n";
#exit;

