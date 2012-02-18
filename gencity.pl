#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
use XML::Simple;
use List::Util 'shuffle';
use POSIX;
my $xml = new XML::Simple;

our $xml_data = $xml->XMLin(   "data.xml", ForceContent => 1, ForceArray  =>[]  );


my $city= build_city();

print Dumper $city;


exit;

####################################################################
####################################################################
####################################################################
####################################################################


sub build_city{
    my $city;
#Steps for generating a random city

# - Generate a size                               check
    $city=set_city_size($city);
# - Generate a type                               check
    $city=set_city_type($city);
# - Generate a name                               check
    $city=generate_city_name($city);
# - Generate a pop_type                           check
    $city=generate_pop_type($city);
# - Generate pop counts                           check
    $city=generate_pop_counts($city);
# - Generate assign races                         check
    $city=assign_races($city);
# - Generate ethics                               check
    $city=generate_city_ethics($city);
# - generate gov't type                           check
    $city=set_govt_type($city);
# - generate gov't type                           check
#    $city=select_landmark($city);
#Time
#taverns
#laws
# - generate religions(weighted by race)
# - generate terrain
# - generate street condition
# - generate natural resources
# - generate map
    return $city;
}

sub set_govt_type{
    my ($city)=@_;
    my @govtypes=@{$xml_data->{'govtypes'}->{'govt'}};
    $city->{'govtype'}=  $govtypes[ &d(scalar @govtypes)-1]->{'type'};
    return $city;
}

sub assign_races{
    my ($city)=@_;
    my $base_pop=$city->{'base_pop'};
    my @available_races=get_races($base_pop);

    my @races;

    for my $race ( @{ $city->{'races'} }  ){
        my $newrace= pop(@available_races);
        $race= add_race_features($race,$newrace);
        push @races, $race;
    }

    if ( $city->{'add_other'} eq 'true' ){
        my $newrace=get_other_race($base_pop);
        my $replace_race=&d(scalar @races )-1;
        $races[$replace_race]=add_race_features($races[$replace_race],$newrace);
    }

    $city->{'races'}=\@races;

    return $city;
}

sub add_race_features{
    my ($race,$newrace)=@_;
    $race->{'name'}=$newrace->{'content'};
    $race->{'order_mod'}=$newrace->{'order_mod'};
    $race->{'moral_mod'}=$newrace->{'moral_mod'};
    $race->{'magic_mod'}=$newrace->{'magic_mod'};
    $race->{'type'}=$newrace->{'type'};
    return $race;
}


sub get_other_race{
    my ($type)=@_;
    my @races;
    for my $race (shuffle @{ $xml_data->{'races'}->{'race'} } ){
        if ($race->{'type'} ne $type){
            return $race;
        }
    }
}
sub get_races {
    my ($type,)=@_;
    my @races;
    for my $race (@{ $xml_data->{'races'}->{'race'} } ){
        if (  $race->{'type'} eq $type     or      $type eq 'mixed'  ){
            push @races, $race;
        }
    }
    return shuffle @races;
}

sub generate_pop_counts{
    my ($city)=@_;
    my $roll= &d(100);
    my $population=$city->{'population'};
    my $newpop=0;
    my @races;
    for my $race ( reverse @{ $city->{'races'} }){
        $race->{'count'}=ceil($population*$race->{'percent'}/100);
        $newpop+=$race->{'count'};
        push @races, $race;
    }
    $city->{'population'}=$newpop;
    $city->{'races'}=\@races;
    my @newraces;
    for my $race ( @{ $city->{'races'} }  ){
        $race->{'percent'}=int($race->{'count'}/$newpop*1000)/10;
        push @newraces, $race;
    }
    $city->{'races'}=\@newraces;
    return $city;
}

sub generate_pop_type{
    my ($city)=@_;
    my $roll= &d(100);
    my $poptype=select_from_array($roll, $xml_data->{'poptypes'}->{'population'});
    $city->{'poptype'}=$poptype->{'type'};
    $city->{'races'}= $poptype->{'option'};
    return $city;
}

sub generate_city_ethics{
    my ($city)=@_;
    $city->{'moral'}=&d(100);
    $city->{'order'}=&d(100);
    $city->{'magic'}=&d(100);
    for my $race ( @{$city->{'races'}} ){
        $city->{'moral'} += $race->{'moral_mod'};
        $city->{'order'} += $race->{'order_mod'};
        $city->{'magic'} += $race->{'magic_mod'};
    }
    if ($city->{'moral'} < 1   ){$city->{'moral'}=1;  }
    if ($city->{'moral'} > 100 ){$city->{'moral'}=100;}
    if ($city->{'order'} < 1   ){$city->{'order'}=1;  }
    if ($city->{'order'} > 100 ){$city->{'order'}=100;}
    if ($city->{'magic'} < 1   ){$city->{'magic'}=1;  }
    if ($city->{'magic'} > 100 ){$city->{'magic'}=100;}
    return $city;
}



sub set_city_size{
    my ($city)=@_;
    my $roll= &d(100);
    my $citysize=select_from_array($roll, $xml_data->{'citysize'}->{'city'});
    $city->{'size'}          = $citysize->{'size'};
    $city->{'gplimit'}       = $citysize->{'gplimit'};
    $city->{'population'}    = $citysize->{'minpop'} + &d( $citysize->{'maxpop'} - $citysize->{'minpop'}  );
    $city->{'size_modifier'} = $citysize->{'size_modifier'};
    
    return $city;
}

sub set_city_type{
    my ($city)=@_;
    my $roll= &d(100);
    my $citytype=select_from_array($roll, $xml_data->{'citytype'}->{'city'});
    $city->{'base_pop'}    = $citytype->{'base_pop'};
    $city->{'type'}        = $citytype->{'type'};
    $city->{'description'} = $citytype->{'content'};
    $city->{'add_other'} = $citytype->{'add_other'};
    return $city;
}

#####################################
# Generate a City Name
# There is the prefix, the root, the suffix and the trailer
sub generate_city_name{
    my ($city)=@_;
    my $cityname;
    for my $partname ( qw( prefix root suffix trailer )  ){
        my $part=$xml_data->{$partname};

        # If no chance is set, or d100 is greater than the chance, add the part.
        if ( !defined $part->{'chance'} or $part->{'chance'} > &d(100) ){
            my @words=@{  $part->{'word'}  };
            my $wordcount=scalar(@words);
            
            $cityname.=  @words[  &d($wordcount)  ]->{'content'};
        }
    }
    $city->{'name'}=$cityname;
    return $city;
}
#######################################################
# Presuming $items is an array of xml object with 
# a min and max property, select the one that $roll 
# best fits.
sub select_from_array{
    my ($roll,$items)=@_;
    my $selected_item=$items->[0];
    for my $item (@$items){
        if (  $item->{'min'} <= $roll  and  $item->{'max'} >= $roll  ){
            $selected_item=$item;
            last;
        }
    }
    return $selected_item;
}

sub d{
#    d as in 1d6
    my ($die)=@_;
    return int(rand($die));
}


####################################################################
####################################################################


# This will be our city datastructure.
#my $city=&generate_city_type();


# generate a city name...

# calculate population size
my $population=int rand($city->{'maxpop'} - $city->{'minpop'})+$city->{'minpop'};

# determine allowed population breakdowns
my @poptypes;
for my $poptype ( @{ $xml_data->{'poptypes'}->{'pop'} } ){
    if ($poptype->{'minpop'} <= $population){
        push @poptypes,$poptype;
    }
}
my $poptype= $poptypes[ &d(scalar(@poptypes))];



# This determines the npc vs monster races in the city.
my $city_type=&d(100);

# break down percentages of races in the city.
my $pop_breakdown=&generate_population($poptype,$city,$city_type);

$city=&racial_ethic_skew($city,$poptype);

#        print "--current ethics: ".$city->{'moral'}."  ".$city->{'order'}."\n";

$city->{'govtype'}=&generate_govtype();


############################################
##  Work out the pretty formatting for the
##  output
#
print "\n\n\t=========  ".$city->{'name'}."  =========\n";
print Dumper($city);
print "\n\t".$city->{'name'}." is ". &determine_city_type($city_type)." ".$city->{'type'}." with a population of around $population.\n";
print "\tThe ".$city->{'type'}." population is ".$poptype->{'type'}.", with the following breakdown:\n";
for my $percentage (@{$pop_breakdown->{'percentage'}}){
    print "\t\t".int(($percentage->{'content'}/100)*$population+1)."\t(".$percentage->{'content'}."%)\t".$percentage->{'race'}->{'content'}."\n";
}
print "\tMorals:\n";
print "\tThe city is ruled by a ";
if (&order_type($city->{'order'}) eq &moral_type($city->{'moral'})){
    print "true neutral";
}else{
    print &order_type($city->{'order'})." ".&moral_type($city->{'moral'});
}
print " ".$city->{'govtype'}." (".$city->{'order'}.",".$city->{'moral'}.").\n";

print "\n\n";
exit;


##############################################################
##############################################################
##############################################################
##############################################################


sub generate_govtype{
    use vars qw ($xml_data);
    return $xml_data->{'govtypes'}->{'govt'}[int rand(scalar(@{$xml_data->{'govtypes'}->{'govt'} }))]->{'type'};
#    return Dumper($xml_data->{'govtypes'}) ;
}

sub racial_ethic_skew{
    my ($city,$poptype)=@_;
    for my $race (@{ $poptype->{'percentage'} }){
#        print "current ethics: ".$city->{'moral'}."  ".$city->{'order'}."\n";
        $city->{'moral'}= $city->{'moral'} + $race->{'race'}->{'moral_mod'};
        $city->{'order'}= $city->{'order'} + $race->{'race'}->{'order_mod'};
    }
    return $city;

}









