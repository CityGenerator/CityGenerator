#!/usr/bin/perl -w
####################################################################
#                     City Generation Script                       #
# Author: Jesse Morgan                                             #
# Purpose: Generate a random city and the conditions               #
####################################################################
use strict;
use Data::Dumper;
use Getopt::Long qw( :config auto_help );
use XML::Simple;
use List::Util 'shuffle';
use POSIX;

#TODO city exports
our $seed;
GetOptions( 'seed=i' => \$seed );
if (defined $seed){
    srand($seed);   
}else{
    $seed=int rand(1000000);
    srand($seed);
}

my $xml = new XML::Simple;
our $xml_data = $xml->XMLin( "data.xml", ForceContent => 1, ForceArray => [] );


my $city = build_city();

my $filename='my_cities/'.$city->{'name'}.'.xml';
open OUT, ">", $filename;
print OUT $xml->XMLout($city);
close OUT;

my $city_description= describe_city($city);

exit;

####################################################################
####################################################################
####################################################################
####################################################################


sub build_city {
    my $city={'seed'=>$seed};
    
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
# - generate secondary powers
    $city = generate_secondary_power($city);
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
# - generate street condition
    $city=generate_streets($city);
# - generate buildings
    $city=generate_buildings($city);
# - Generate Districts
    $city=generate_districts($city);
    
#taverns
# - generate religions(weighted by race)
# - generate map
    return $city;
}
sub generate_districts{
    my ($city) = @_;
    my $districtcount=5 + $city->{'size_modifier'};
    $city->{'districts'}={};
    for (my $i=0; $i<$districtcount ; $i++){
        my $district=rand_from_array(@{$xml_data->{'districts'}->{'option'}});
        if (defined $city->{'districts'}->{$district->{'type'}}){
            $city->{'districts'}->{$district->{'type'}}+=1;
        }else{
            $city->{'districts'}->{$district->{'type'}}=1;
        }
    }
    return $city;
}


sub generate_buildings{
    my ($city) = @_;
    my $pop=$city->{'population'};
    
    $city->{'housing'}={};
    $city->{'housing'}->{'average'}     = floor($pop*.69/10);
    $city->{'housing'}->{'poor'}        = ceil ($pop*.30/20);
    $city->{'housing'}->{'elite'}       = floor($pop*.01/5);
    $city->{'housing'}->{'total'}       = $city->{'housing'}->{'average'} + $city->{'housing'}->{'poor'} + $city->{'housing'}->{'elite'};
    $city->{'housing'}->{'abandoned'}   = floor($city->{'housing'}->{'total'} *(10-$city->{'economy'} )/100 );

    $city->{'business'}={  'total'=>0  };

    my $businessestimate=($city->{'population'}/10)-$city->{'housing'}->{'total'};

    for my $business (  @{ $xml_data->{'buildings'}->{'building'} }   ){
        my $businessname=$business->{'content'};
        my $businesspercent=$business->{'percent'}+$city->{$business->{'type'}};
        if ($businesspercent <0){ $businesspercent=0; }
        if ($businesspercent >10){ $businesspercent=10; }

        my $businesscount=ceil $businessestimate*($businesspercent)/100;
        $city->{'business'}->{$businessname}={ 
                                                'origpercent'=>$business->{'percent'},
                                                'racepercent'=>$city->{$business->{'type'}},
                                                'percent' =>$businesspercent,
                                                'count'=> $businesscount,
                                             };
        $city->{'business'}->{'total'}+=$city->{'business'}->{$businessname}->{'count'};
    }
    #print Dumper $city;
    return $city;
}


sub generate_streets{
    my ($city) = @_;
    my $pop=$city->{'population'};
    my $timemodifier=$city->{'time'}->{'public_modifier'};
    my $sizemodifier=$city->{'size_modifier'};

    my $visiblepop=ceil($pop/(10+$sizemodifier) );

    if ($timemodifier >0){
        $visiblepop=$visiblepop*$timemodifier;
    }elsif ($timemodifier <0){
        $visiblepop=ceil sqrt($visiblepop/abs($timemodifier))+abs($timemodifier);
        if ($sizemodifier >0){
            $visiblepop*=$sizemodifier;
        }
    }
  
    if (defined $city->{'weather'}->{'precip'} ) {
        $visiblepop=ceil($visiblepop/2);
    }
    if (defined $city->{'weather'}->{'thunder'} ) {
        $visiblepop=ceil($visiblepop/2);
    }
    $visiblepop=ceil($visiblepop*$city->{'weather'}->{'temp'}->{'modifier'});

    $city->{'visible population'}=$visiblepop;
 
    
# Determine population out on the streets= populatio
    return $city;
}


sub generate_markets {
    my ($city) = @_;
    my @markets;
    for my $market (@{ $xml_data->{'markets'}->{'option'} } ){
        if (&d(100) < $market->{'chance'}){
            my $newmarket->{'type'}=$market->{'type'};
            $newmarket->{'name'}=$market->{'marketname'}.' '.$market->{'type'};
            if ( &d(100) <$market->{'secret'} ){
                $newmarket->{'secret'}='(secret)';
            }else{
                $newmarket->{'secret'}='';
            }
            if ( &d(100) > 50 ){
                my $marketoption=rand_from_array(@{$market->{'option'}});
                $newmarket->{'name'}= $marketoption->{'content'}.' '.$newmarket->{'name'};
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
            = rand_from_array( @{ $xml_data->{'weather'}->{$facet}->{'option'} } );
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
            my $landmarkname=$landmark->{'content'};
            if ( &d(100) < $xml_data->{'locations'}->{'landmarkdesc'}->{'chance'} ){
                my @landmarkdesc=@{ $xml_data->{'locations'}->{'landmarkdesc'}->{'option'} };
                $landmarkname = rand_from_array( @landmarkdesc )->{'content'}.' '.$landmarkname;
            }
            push @landmarks, $landmarkname;
        }
    }
    return \@landmarks;
} ## end sub set_landmarks

sub rand_from_array {
    my (@array) = @_;
    my $index = int( rand( scalar @array ) );
    return $array[$index];
}

sub generate_secondary_power {
    my ($city) = @_;
    $city->{'secondarypower'}={};
    $city->{'secondarypower'}->{'plot'} = rand_from_array( @{ $xml_data->{'secondarypower'}->{'plot'} } )->{'content'};
    my $power = rand_from_array( @{ $xml_data->{'secondarypower'}->{'power'} } );
    $city->{'secondarypower'}->{'power'} = $power->{'type'};
    $city->{'secondarypower'}->{'subplot'} = rand_from_array( @{ $power->{'subplot'} } )->{'content'};
    return $city;
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
    delete $city->{'add_other'};
    $city->{'races'} = \@races;

    return $city;
} ## end sub assign_races

sub add_race_features {
    my ( $race, $newrace ) = @_;
    $race->{'name'}      = $newrace->{'content'};
    $race->{'order'}     = $newrace->{'order'};
    $race->{'moral'}     = $newrace->{'moral'};
    $race->{'magic'}     = $newrace->{'magic'}; 
    $race->{'authority'} = $newrace->{'authority'};
    $race->{'economy'}   = $newrace->{'economy'};
    $race->{'education'} = $newrace->{'education'};
    $race->{'travel'}    = $newrace->{'travel'};
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
    my $popdensity = rand_from_array( @{$xml_data->{'popdensity'}->{'option'} });
    $city->{'poptype'} = $poptype->{'type'};
    $city->{'popdensity'} = $popdensity;
    $city->{'races'}   = $poptype->{'option'};
    return $city;
} ## end sub generate_pop_type

sub generate_city_ethics {
    my ($city) = @_;
    $city->{'moral'} = &d(100);
    $city->{'order'} = &d(100);
    $city->{'magic'}    =&d(4)-2;
    $city->{'authority'}=&d(4)-2;
    $city->{'economy'}  =&d(4)-2;
    $city->{'education'}=&d(4)-2;
    $city->{'travel'}   =&d(4)-2;
    for my $race ( @{ $city->{'races'} } ) {
        $city->{'moral'} += $race->{'moral'};
        $city->{'order'} += $race->{'order'};
        $city->{'magic'} += $race->{'magic'};
        $race->{'authority'} += $race->{'authority'};
        $race->{'economy'}   += $race->{'economy'};
        $race->{'education'} += $race->{'education'};
        $race->{'travel'}    += $race->{'travel'};
    }
    if ( $city->{'moral'} <   1 )    { $city->{'moral'} =   1; }
    if ( $city->{'moral'} > 100 )    { $city->{'moral'} = 100; }
    if ( $city->{'order'} <   1 )    { $city->{'order'} =   1; }
    if ( $city->{'order'} > 100 )    { $city->{'order'} = 100; }
    if ( $city->{'magic'}     < -5 ) { $city->{'magic'}      = -5; }
    if ( $city->{'magic'}     >  5 ) { $city->{'magic'}      =  5; }
    if ( $city->{'authority'} < -5 ) { $city->{'authority'}  = -5; }
    if ( $city->{'authority'} >  5 ) { $city->{'authority'}  =  5; }
    if ( $city->{'economy'}   < -5 ) { $city->{'economy'}    = -5; }
    if ( $city->{'economy'}   >  5 ) { $city->{'economy'}    =  5; }
    if ( $city->{'education'} < -5 ) { $city->{'education'}  = -5; }
    if ( $city->{'education'} >  5 ) { $city->{'education'}  =  5; }
    if ( $city->{'travel'}    < -5 ) { $city->{'travel'}     = -5; }
    if ( $city->{'travel'}    >  5 ) { $city->{'travel'}     =  5; }
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

sub print_markets_and_landmarks{
    my ($city)=@_;
    my $places='';
    if (defined $city->{markets} or defined $city->{'landmarks'}){
        $places="\nWithin the city and the surrounding areas, you'll find:\n";
    }

    if (defined $city->{markets}){
        for my $market ( @{$city->{'markets'}}){
            $places.=sprintf "    * %s %s\n", $market->{'name'}, $market->{'secret'} ;
        }
    }
    if ( defined $city->{'landmarks'}){
        for my $landmark ( @{$city->{'landmarks'}}){
            $places.=sprintf "    * a %s\n", $landmark;
        }
    }
    return $places;
}
sub print_precip{
    my ($city)=@_;
    my $precip='';
    if ( defined $city->{'weather'}->{'precip'} ){
        $precip="It is ".$city->{'weather'}->{'precip'}.".\n";
    }
    if ( defined $city->{'weather'}->{'thunder'} ){
        $precip="There is thunder ".$city->{'weather'}->{'thunder'}.".\n";
    }
    return $precip;
}
#######################################################
# Pass in a $city structure, and print out a wonderful
# wall of text describing the city, sorta like a mad lib
sub describe_city{
    my ($city)=@_;
    my $events= join "\n    * ",@{$city->{'events'}};

    my $markets=print_markets_and_landmarks($city);

    my $precip=print_precip($city);

    my $population='';
    for my $race (reverse sort {$a->{'count'} <=> $b->{'count'}}  @{$city->{'races'}}){
        $population.=sprintf "    * %5d  %13s ( %4s%%)\n",$race->{'count'}, $race->{'name'}, $race->{'percent'};
    }

    my $clouds='';
    if ( defined $city->{'weather'}->{'clouds'} ){
        $clouds="the clouds are ".$city->{'weather'}->{'clouds'}.",";
    }
    my $economy=print_economy($city);
    my $housing=print_housing($city);
    my $districts=print_districts($city);

print <<EOF

========== $city->{'name'} ($city->{'seed'})==========

$city->{'name'} is a $city->{'description'} of around $city->{'population'}.
Located $city->{'location'}, this $city->{'poptype'} $city->{'size'} is ruled by $city->{'govtype'}->{'type'},
although there is a $city->{'secondarypower'}->{'power'} that $city->{'secondarypower'}->{'plot'} the leadership, 
while secretly $city->{'secondarypower'}->{'subplot'}.
$markets
You arrive at the city around $city->{'time'}->{'content'}, where $clouds the air is $city->{'weather'}->{'air'}->{'content'} 
and the wind is $city->{'weather'}->{'wind'}->{'content'}. $precip

Upon arrival, around $city->{'visible population'} citizens are wandering the $city->{'weather'}->{'temp'}->{'content'} $city->{'size'}. You see:
    * $events

Law enforcement $city->{'laws'}->{'enforcement'}, punishments are mainly $city->{'laws'}->{'punishment'},
and convictions are $city->{'laws'}->{'trial'}.
$economy 
$housing
$districts

Populations is broken down as follows:
$population
EOF
;

}

sub print_districts{
    my ($city)=@_;
    my $districts="\nDistricts:\n";
    my $loop=0;
    for my $district (sort keys %{ $city->{'districts'}}  ){
        $districts.=sprintf " %2s %-12s",$city->{'districts'}->{$district},$district;
        if ($loop++ %3 == 2){$districts.="\n";}
    }

    return $districts;
}

sub print_housing{
    my ($city)=@_;
    my $housing="\nHousing:\n";
    $housing.=sprintf "  Abandoned: %4s   ",  $city->{'housing'}->{'abandoned'};
    $housing.=sprintf "  Average:   %4s   \n",  $city->{'housing'}->{'average'};
    $housing.=sprintf "  Poor:      %4s   ",$city->{'housing'}->{'poor'};
    $housing.=sprintf "  Elite:     %4s   \n",  $city->{'housing'}->{'elite'};

    return $housing;
}
sub print_economy{
    my ($city)=@_;
    my $econ="\nEconomy:\n The economy is ";
    if ($city->{'economy'} >0){ $econ.='strong. ';
    }elsif ($city->{'economy'} <0){ $econ.='weak. ';
    }else { $econ.='stable. ';    }
    $econ.="Magic is ";
    if ($city->{'magic'} >0){ $econ.='plentiful. ';
    }elsif ($city->{'magic'} <0){ $econ.='rare. ';
    }else { $econ.=' somewhat common. ';    }
    $econ.="Education is ";
    if ($city->{'education'} >0){ $econ.="high.\n ";
    }elsif ($city->{'education'} <0){ $econ.="low.\n ";
    }else { $econ.="somewhat common.\n ";    }
    if ($city->{'travel'} >0){ $econ.='This is a trade hub with many travelers. ';
    }elsif ($city->{'education'} <0){ $econ.='This is an economically isolated area with few travelers. ';}

    $econ.="You can find the following businesses:\n";
    my $businesstypes=$city->{'business'};
    my $loop=0;
    for my $businessname (sort keys  %$businesstypes  ){
        if ($businessname ne 'total'){
            $econ.=sprintf "  %4s %-15s",$businesstypes->{$businessname}->{'count'},$businessname;
        }
        if ($loop++ %3 == 2){$econ.="\n";}
    }
    return $econ;
}

# Note that this function is purely for testing purposes.
sub test_visible_pop{
    my $sizes={
               -5 =>20,                -2 =>1000,
                0 =>3500,               2 =>5000,
                4 =>8000,               6 =>15000,
               12 =>50000,
                };
    
    printf " %10s %10s | %10s %10s %10s %10s %10s %10s %10s %10s %10s \n", 'population','size_mod',-4,-3,-2,-1,0,1,2,3,4 ;
    print "-" x 125 ."\n";
    for my $size (sort {$a <=> $b} keys %$sizes ){
        $city->{'size_modifier'}=$size;
        $city->{'population'}=$sizes->{$size};
        print_pop_info($city);
        for my $time (qw/ -4 -3 -2 -1 0 1 2 3 4 / ){
            $city->{'time'}->{'public_modifier'}=$time;
            $city = generate_streets($city);
            printf " %10s",$city->{'visible population'},
        }
        print "\n"
    }
    exit;

}
# Note that this function is purely for testing purposes.
sub print_pop_info{
    my ($city) = @_;
    printf " %10s %10s |", $city->{'population'}, $city->{'size_modifier'};
}
