#!/usr/bin/perl -w
# This code is a cluster fuck.
#
use strict;
use Data::Dumper;
use XML::Simple;

my $xml = new XML::Simple;

my $xml_data = $xml->XMLin(   "data.xml", ForceContent => 1, ForceArray  =>[]  );


#Steps for generating a random city
# - Generate a size                               check
# - Generate a name                               check
# - Generate a pop_type                           check
# - Generate races                                check
# - generate city pop-breakdown                   check
# - generate magic disposition
# - generate Magic level (weighted for mages & dispostion)
# - generate city alignment
# - generate gov't type
# - generate religions(weighted by race)
# - generate terrain
# - generate street condition
# - generate natural resources
# - generate map



# This will be our city datastructure.
my $city=&generate_city_type();


# generate a city name...
$city->{'name'}= generate_city_name();

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
$city->{'moral'}=&d(100);
$city->{'order'}=&d(100);

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





sub determine_city_type{
    my ($val)=@_;
    my $type;
    # bad coding on my part here- these values are hardcoded 
    # here and in generate_population().
    if ($val<70){
        $type="a normal";
    }elsif($val<80){
        $type="a fairly normal";
    }elsif($val<95){
        $type="a monsterous";
    }else{
        $type="an open";
    }
    return $type;
}

sub moral_type{
    use vars qw ($xml_data);
    my ($val)=@_;
    if ($val < $xml_data->{'moralalignment'}->{'neutralmin'}){
        return "evil";
    }elsif($val > $xml_data->{'moralalignment'}->{'neutralmax'}){
        return "good";
    }else{
        return "neutral";
    }
}
sub order_type{
    use vars qw ($xml_data);
    my ($val)=@_;
    if ($val < $xml_data->{'orderalignment'}->{'neutralmin'}){
        return "chaotic";
    }elsif($val > $xml_data->{'orderalignment'}->{'neutralmax'}){
        return "lawful";
    }else{
        return "neutral";
    }
}



sub generate_population{
    use vars qw ( $xml_data );
    my ($poptype,$city,$city_type)=@_;
    my $num_of_races=scalar(@{$poptype->{'percentage'}});
    
    my @basic_races;
    my @uncommon_races;
    my @monster_races;
    for my $race (@{$xml_data->{'races'}{'race'}}){
        if ($race->{'type'} eq 'basic'){
            push @basic_races,$race;
        }
    }
    for my $race (@{$xml_data->{'races'}{'race'}}){
        if ($race->{'type'} eq 'uncommon'){
            push @uncommon_races,$race;
        }
    }
    for my $race (@{$xml_data->{'races'}{'race'}}){
        if ($race->{'type'} eq 'monster'){
            push @monster_races,$race;
        }
    }

#    print "pop rand is $city_type\n"; 
    if ($city_type < 70){# normal basic city
    #-------------------------------
        print "a basic city\n";
#        print "tabulate common races\n";
        for (my $i=0; $i<2; $i++) {
        
            my $temp_race=$basic_races[ int(rand(@basic_races))  ];
            
            $poptype->{'percentage'}[$i]->{'race'}=$temp_race;
#            print "selected common race: $temp_race->{'content'}\n";
            @basic_races = grep( {$temp_race ne $_}  @basic_races); 
        }

#        print "tabulate uncommon races\n";
#        print "=====================\n";
        
        push (@basic_races,@uncommon_races);
#        print "races left:\n";
#        print Dumper(@basic_races);
        
        for (my $i=0; $i<$num_of_races-2; $i++) {
            my $temp_race=$basic_races[ int(rand(@basic_races))  ];
#            print "selected uncommon race: $temp_race->{'content'}\n";
            
            $poptype->{'percentage'}[$i+2]->{'race'}=$temp_race;
            @basic_races = grep( {$temp_race ne $_}  @basic_races); 
        }
#       print Dumper($poptype);
#       exit;
       
    }elsif($city_type < 80){# one monster race
     #------------------------------
        print "a basic city plus one monster\n";
#        print "tabulate common races\n";
        for (my $i=0; $i<2; $i++) {
        
            my $temp_race=$basic_races[ int(rand(@basic_races))  ];
            
            $poptype->{'percentage'}[$i]->{'race'}=$temp_race;
            @basic_races = grep( {$temp_race ne $_}  @basic_races); 
        }

#        print "tabulate uncommon races\n";
        
        push @basic_races,@uncommon_races;
        for (my $i=0; $i<$num_of_races-3; $i++) {
            my $temp_race=$basic_races[ int(rand(@basic_races))  ];
            
            $poptype->{'percentage'}[$i+2]->{'race'}=$temp_race;
            @basic_races = grep( {$temp_race ne $_}  @basic_races); 
        }

        $poptype->{'percentage'}[@{$poptype->{'percentage'}}-1]->{'race'}=$monster_races[int rand (@monster_races)];
     
    
    }elsif($city_type < 95){#monster city
     #------------------------------
        print "a monster city \n";
        for (my $i=0; $i<$num_of_races; $i++) {
            my $temp_race=$monster_races[int rand (@monster_races)];
            $poptype->{'percentage'}[$i]->{'race'}=$temp_race;
            @monster_races = grep( {$temp_race ne $_}  @monster_races); 
        }
    
    }else{ # completely random
     #------------------------------
        print "a random city \n";
        my @all_races=( @basic_races, @monster_races);
#        print "tabulate common races\n";
        for (my $i=0; $i<2; $i++) {
        
            my $temp_race=$all_races[ int(rand(@all_races))  ];
#            print "selected common race: ".$temp_race->{'content'}."\n";
            $poptype->{'percentage'}[$i]->{'race'}=$temp_race;
            @all_races = grep( {$temp_race ne $_}  @all_races); 
        }

#        print "tabulate uncommon races\n";
        
        push @all_races,@uncommon_races;
        for (my $i=0; $i<$num_of_races-2; $i++) {
            my $temp_race=$all_races[ int(rand(@all_races))  ];
#            print "selected common race: $temp_race->{'content'}\n";
            
            $poptype->{'percentage'}[$i+2]->{'race'}=$temp_race;
            @all_races = grep( {$temp_race ne $_}  @all_races); 
        }

    }

#########################
# calculate city alignment drift


    return $poptype;
#    exit;
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


sub d{
#    d as in 1d6
    my ($die)=@_;
    return int(rand($die));
}



sub generate_city_name{
    #####################################
    # Generate a City Name
    # There is the prefix, the root, the suffix and the trailer
    # 
    use vars qw ( $xml_data );
    my $cityname="";
    if ($xml_data->{'prefix'}->{'chance'} > &d(100)){
        $cityname.= $xml_data->{'prefix'}->{'word'}[  &d(scalar(@{  $xml_data->{'prefix'}->{'word'}  }))    ]->{'content'}." ";
    }
    $cityname.= $xml_data->{'root'}->{'word'}[  &d(scalar(@{  $xml_data->{'root'}->{'word'}  }) )]->{'content'};
    $cityname.= $xml_data->{'suffix'}->{'word'}[ &d(scalar(@{  $xml_data->{'suffix'}->{'word'}  }) )]->{'content'};
    if ($xml_data->{'trailer'}->{'chance'} > &d(100)){
        $cityname.= " ".$xml_data->{'trailer'}->{'word'}[    &d(scalar(@{  $xml_data->{'trailer'}->{'word'}  }) )]->{'content'};
    }

    return $cityname;
}





sub generate_city_type{
    # TODO: there has to be a cleaner way to implement this...
    use vars qw ( $xml_data );
    my $city_type_roll= &d(100);
    my $city;
    for my $citytype (@{ $xml_data->{'cities'}->{'city'} }){
        if (    $citytype->{'min'} <=  $city_type_roll   and    $citytype->{'max'} >= $city_type_roll  ){
            $city=$citytype;
            last;
        }
    }
    return $city;

}
