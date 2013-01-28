#!/usr/bin/perl -wT
###############################################################################
#
package City;


use strict;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( build_city set_seed d roll_from_array rand_from_array generate_name);


use CGI;
use Data::Dumper;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;

my $xml = new XML::Simple;

our $xml_data   = $xml->XMLin( "../data.xml",  ForceContent => 1, ForceArray => ['option'] );
our $names_data = $xml->XMLin( "../names.xml", ForceContent => 1, ForceArray => [] );
our $seed;
our $originalseed;
our $city;

#TODO generate trivia
#TODO generate a random house and the contents based on wealth of city, owner of the house, size of the family, etc
#TODO generate content of stores
#TODO city seal, stone, coat of arms, animal, beverages, colors, foods, motto, nicknames, symbol (bird, tree, etc)


#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################



###############################################################################
#
# build_city - This is the primary method for building a city. using $seed,
# generate the city name, then the core, creedence, physical traits, economy,
# military and current events. Once that's finished you have a fully
# funcitonal city.
#
###############################################################################

sub build_city {
     ($originalseed) = @_;
    $seed           = set_seed($originalseed);
    $city->{'name'} = generate_name($seed);
    $city->{'debug'}='';
    generate_realm();
    generate_continent();

    generate_city_core();
    generate_city_credence();
    generate_physical_traits();
    generate_economics();
    generate_military();
    generate_culture();
    generate_current_events();
    generate_people();
    return $city;
} ## end sub build_city



sub generate_name {
    my ($newseed) = @_;
    $seed           = set_seed($newseed);
    $city           = { 'seed' => $seed };
    return parse_object( $xml_data->{'cityname'} )->{'content'};
}

###############################################################################
#
# generate_city_core - select the size, type, population, races and population
# breakdown. This is the core of the city stats, everything else is icing.
#
###############################################################################

sub generate_city_core {
    set_city_size();
    set_city_type();
    generate_pop_type();
    assign_races();
    generate_pop_counts();
    generate_city_age();
    generate_children();
    generate_elderly();
} ## end sub generate_city_core

###############################################################################
#
# generate_city_credence - select government, ethics, tolerance, etc.
#
###############################################################################

sub generate_city_credence {
    generate_city_ethics();
    generate_city_beliefs();
    set_govt_type();
    generate_secondary_power();
    set_laws();
    generate_crime();
    generate_imprisonment_rate();
} ## end sub generate_city_credence

###############################################################################
#
# generate_physical_traits - Generate the location, size, support area,
# landmarks,
#
###############################################################################

sub generate_physical_traits {
    generate_location();
    generate_climate();
    generate_housing();
    generate_area();
    generate_support_area();
    generate_businesses();
    generate_districts();
    generate_streets();
    generate_walls();
    generate_watchtowers();
    generate_shape();
    generate_neighbors();
    generate_topography();
} ## end sub generate_physical_traits

###############################################################################
#
# generate_economics - generate various markets, organizations and resources
#
###############################################################################

sub generate_economics {
    generate_markets();
    generate_resources();
    generate_taverns();
    generate_economic_description();
    generate_education_description();
    print "======== $seed\n";
    generate_magic_description();
} ## end sub generate_economics

###############################################################################
#
# generate_military - generate military, fortifications, wars, etc
#
###############################################################################

sub generate_military {
    generate_military_stats();
    generate_fortifications();
    generate_kingdom_troops();
    generate_favored_weapon();
    generate_favored_tactic();
    generate_military_skill();

    #    generate_seige();
} ## end sub generate_military

###############################################################################
#
# generate_culture - generate cultural things
#
###############################################################################
sub generate_culture {
    generate_flag_colors();
    generate_city_crest();
} ## end sub generate_culture

###############################################################################
#
# generate_current_events - generate weather conditions, visible population,
# and ongoing events.
#
###############################################################################
sub generate_current_events {
    generate_time();
    generate_weather();
    generate_visible_population();
    generate_events();
} ## end sub generate_current_events

###############################################################################
#
# generate_people - generate citizens and travelers of note.
#
###############################################################################
sub generate_people {
    generate_citizens();
    generate_travelers();
}

###############################################################################
#
# generate_citizens - given all of our specialists, are any noteworhy?
#
###############################################################################
sub generate_citizens {

    my $limit = $city->{'specialisttotal'};
    # no less than 0, no more than specialisttotal.
    my $citizencount = min( $city->{'specialisttotal'}, int( &d( 6 + $city->{'size_modifier'} ) - 1 ) );

    $city->{'citizens'} = [];
    my $businesslist = $city->{'business'};
    while ( $citizencount-- > 0 ) {
        $seed++;
        my $race    = rand_from_array( $city->{'races'} );
        my $citizen = generate_npc_name( lc $race->{'content'} );
        $citizen->{'skill'}    = roll_from_array( &d(100), $xml_data->{'skill'}->{'level'} )->{'content'};
        $citizen->{'behavior'} = rand_from_array( $xml_data->{'behavioraltraits'}->{'trait'} )->{'type'};
        $citizen->{'scope'}    = rand_from_array( $xml_data->{'area'}->{'scope'} )->{'content'};
        $citizen->{'race'}     = $race;
        my @keys         = shuffle keys %$businesslist;
        my $businessname = pop @keys;
        $citizen->{'job'} = $businesslist->{$businessname}->{'profession'} || $businessname;
        delete $businesslist->{$businessname};

        if ( scalar keys %$businesslist == 0 ) {
            $businesslist = $city->{'business'};
        }
        push @{ $city->{'citizens'} }, $citizen;
    } ## end while ( $citizencount-- >...)
    set_seed($originalseed);
} ## end sub generate_citizens

###############################################################################
#
# generate_watchtowers
#
###############################################################################

sub generate_watchtowers {

# inner wall is 1245 with 29 towers, meaning towers every 43 yards; 96876 square meters
# outer wall is 1320 with 18 towers, meaning every 73

    # Determine  walled area - only the city core is walled;
    # best way to calculate that is population@ max density 
    my $protectedcitizens = $city->{'population'}->{'wealthy'}+$city->{'population'}->{'average'};
    my $protectedfeet     = $protectedcitizens*$city->{'popdensity'}->{'feetpercapita'}; #nominal density
    my $protectedhectares = int($protectedfeet/107639*100)/100;
    $city->{'walls'}->{'protectedarea'}= $protectedhectares;
    $city->{'walls'}->{'protectedpercent'}= int($protectedhectares/$city->{'area'}*1000)/10;
    $city->{'walls'}->{'length'}= int(sqrt($protectedhectares )*100*4);
    $city->{'walls'}->{'towercount'}=$city->{'walls'}->{'length'} / ( 100 + $city->{'size_modifier'}*$city->{'popdensity'}->{'feetpercapita'}/1000);
    $city->{'walls'}->{'towercount'}=int($city->{'walls'}->{'towercount'} * (1+ ($city->{'economy'}*2/100  ) ));
}

###############################################################################
#
# generate_city_crest - generate colors and the design
#
###############################################################################

sub generate_city_crest {
    $city->{'crest'}={};
    #TODO finish this after work

}
###############################################################################
#
# generate_shape - generate the rough shape of the city.
#
###############################################################################

sub generate_shape {
    $city->{'shape'}=rand_from_array($xml_data->{'cityshape'}->{'option'})->{'content'};

}
###############################################################################
#
# generate_flag_colors - generate colors and their meanings
#
###############################################################################

sub generate_flag_colors {
    $city->{'flag'}={'colors'=>[] };
    my $colorcount=5;
    my @colors=shuffle @{$xml_data->{'flagcolors'}->{'color'}};
    while ($colorcount-- >0){
        $seed++;
        my $color=pop @colors;
        if ( ref( $color->{'meaning'}) eq 'ARRAY'){
            $color->{'meaning'}=rand_from_array($color->{'meaning'})->{'content'};
        }
        if ( ref( $color->{'shade'}) eq 'ARRAY'){
            my $shade=rand_from_array($color->{'shade'});
            $color->{'hex'} = sprintf ("#%2.2X%2.2X%2.2X",$shade->{'red'},$shade->{'green'},$shade->{'blue'});
            $color->{'type'}=$shade->{'type'};
        }elsif ( ref( $color->{'shade'}) eq 'HASH'){
            $color->{'hex'} = sprintf ("#%2.2X%2.2X%2.2X",$color->{'shade'}->{'red'},$color->{'shade'}->{'green'},$color->{'shade'}->{'blue'});
            $color->{'type'}=$color->{'shade'}->{'type'};
        }
        delete $color->{'shade'};
        push @{$city->{'flag'}->{'colors'}}, $color ;
    }
    set_seed($originalseed);
}


###############################################################################
#
# generate_military_skill - generate favored_tactic, fortifications, wars, etc
#
###############################################################################

sub generate_military_skill {
    $city->{'militaryskill'}={};

    my $roll;
    if ( $city->{'military'} < -1 ) {
        $roll=&d(45);
    }elsif ( $city->{'military'} > 1 ) {
        $roll=56+ &d(45);
    }else{
        $roll=&d(100);
    }
    $city->{'militaryskill'}->{'roll'}=$roll;
    $city->{'militaryskill'}->{'content'}=roll_from_array( $roll, $xml_data->{'preparation'}->{'option'})->{'content'};

}

###############################################################################
#
# generate_favored_tactic - generate favored_tactic, fortifications, wars, etc
#
###############################################################################

sub generate_favored_tactic {
    $city->{'tactics'}={};

    # only a 25% chance of having a favored tactic.
    $city->{'tactics'}->{'chance'}=&d(100);
    if ( $city->{'tactics'}->{'chance'}  <= 25){

        my $tactic=rand_from_array(    $xml_data->{'tactictypes'}->{'option'} );
        $city->{'tactics'}->{'content'}= $tactic->{'content'};
    
        my $respectlist=$xml_data->{'respect'}->{'option'} ;
        my $respect = rand_from_array(  $respectlist  );
        $city->{'tactics'}->{'respect'}=$respect->{'content'};
    }

}
###############################################################################
#
# generate_favored_weapon - generate favored_weapon, fortifications, wars, etc
#
###############################################################################

sub generate_favored_weapon {
    $city->{'weapons'}={};
    my $weaponclass=rand_from_array(    $xml_data->{'weapontypes'}->{'weapon'} );
    $city->{'weapons'}->{'type'}   =  $weaponclass->{'type'} ;
    $city->{'weapons'}->{'content'}=rand_from_array(    $weaponclass->{'option'} )->{'content'};

    my $respectlist=$xml_data->{'respect'}->{'option'} ;
    my $respect = rand_from_array(  $respectlist  );
    $city->{'weapons'}->{'respect'}=$respect->{'content'};

}

###############################################################################
#
# generate_kingdom_troops - generate troops dedicated to protecting the kingdom.
#
###############################################################################

sub generate_kingdom_troops {
    $city->{'militarystats'}->{'kingdompercent'}=max(0, &d(8)*5 + $city->{'size_modifier'});
    
    $city->{'militarystats'}->{'kingdom'}       = int($city->{'militarystats'}->{'active'} * $city->{'militarystats'}->{'kingdompercent'}/100);
    $city->{'militarystats'}->{'kingdompercent'}= int($city->{'militarystats'}->{'kingdom'}/ $city->{'militarystats'}->{'active'} * 1000)/10;
    
}

###############################################################################
#
# generate_fortifications - generate fortifications
#
###############################################################################

sub generate_fortifications {
    my $roll;
    if ($city->{'walls'}->{'content'} eq 'none' ){
        $roll=&d(45);
        $city->{'fortification'}=roll_from_array( $roll  ,$xml_data->{'preparation'}->{'option'}) ;
    }else{
        $roll=&d(100) + $city->{'walls'}->{'height'};
        $city->{'fortification'}=roll_from_array( $roll  ,$xml_data->{'preparation'}->{'option'}) ;
    }
    $city->{'fortification'}->{'roll'}=$roll;
}

###############################################################################
#
# generate_military_stats - generate percentage of militant population
#
###############################################################################

sub generate_military_stats {
    $city->{'militarystats'}={};
    #factors - is there a barraks district? +10%
    # order, mil, authority,
    # base military
    $city->{'militarystats'}->{'activepercent'}  =  max(0, 10 + $city->{'military'} + ($city->{'govtype'}->{'mil_mod'}  +  $city->{'authority'})/2  );
    $city->{'militarystats'}->{'reservepercent'} =  max(0,  3 + $city->{'military'} + ($city->{'govtype'}->{'mil_mod'}  +  $city->{'authority'})/4   ) ;
    $city->{'militarystats'}->{'parapercent'}    =  max(0,  7 + $city->{'military'} +  $city->{'govtype'}->{'mil_mod'} );
    $city->{'militarystats'}->{'inelegable_pop'} = ceil( $city->{'population'}->{'imprisonment'}->{'population'} + $city->{'population'}->{'children'}->{'population'}/2 +$city->{'population'}->{'elderly'}->{'population'});

    $city->{'militarystats'}->{'active'}  =  ceil($city->{'population'}->{'size'}                * $city->{'militarystats'}->{'activepercent'}/100)  ;
    $city->{'militarystats'}->{'reserve'} =  ceil($city->{'population'}->{'size'}                * $city->{'militarystats'}->{'reservepercent'}/100) ;
    $city->{'militarystats'}->{'para'}    =  ceil($city->{'militarystats'}->{'active'} * $city->{'militarystats'}->{'parapercent'}/100)    ;
    $city->{'militarystats'}->{'militia'} =  ceil($city->{'population'}->{'size'} - $city->{'militarystats'}->{'inelegable_pop'} );

    $city->{'militarystats'}->{'activepercent'}  = ceil(  $city->{'militarystats'}->{'active'}/$city->{'population'}->{'size'}*10000  )/100;
    $city->{'militarystats'}->{'reservepercent'} = ceil(  $city->{'militarystats'}->{'reserve'}/$city->{'population'}->{'size'}*10000  )/100;
    $city->{'militarystats'}->{'parapercent'}    = ceil(  $city->{'militarystats'}->{'para'}/$city->{'militarystats'}->{'active'} *10000  )/100;
    $city->{'militarystats'}->{'militiapercent'} = ceil(  $city->{'militarystats'}->{'militia'}/$city->{'population'}->{'size'}*10000  )/100;
    
}

###############################################################################
#
# generate_events - determine what is going on in the city currently.
#
###############################################################################
sub generate_events {
    my $event_chance=$xml_data->{'events'}->{'chance'};
    my $limit=max(2, $city->{'size_modifier'}/2);
    $city->{'eventslimit'}=$limit;
    $city->{'events'}=[];
    my @events;
    for my $event (shuffle @{ $xml_data->{'events'}->{'event'} } ){
        $seed++;
        if ($limit > 0 ){
            my $eventname=$event->{'type'};
            my $desc = rand_from_array(  $event->{'option'}  )->{'content'};
            push @{$city->{'events'}}, $desc.$eventname;
            $limit--;
        }
    }
    set_seed($originalseed);

}


###############################################################################
#
# generate_visible_population - determine what percentage of the population is
# out and about.
#
###############################################################################
sub generate_visible_population {

    my $pop=$city->{'population'}->{'size'};
    my $timemodifier=$city->{'time'}->{'public_modifier'};
    my $sizemodifier=$city->{'size_modifier'};

    # baseline visiblepop is 1/(10+ size modifier) of the population
    my $visiblepop=ceil($pop/(10+$sizemodifier) );

    if ($timemodifier >0){
        $visiblepop=$visiblepop*$timemodifier;
    }elsif ($timemodifier <0){
        # fancy calculation to make less people at night and more in the day
        # I don't remember how this worked out so well.
        $visiblepop=ceil sqrt($visiblepop/abs($timemodifier))+abs($timemodifier);
        if ($sizemodifier >0){
            $visiblepop*=$sizemodifier;
        }
    }

    # If it's raining/snowing/etc, cut the population in half
    if (defined $city->{'weather'}->{'precip'} ) {
        $visiblepop=ceil($visiblepop/2);
    }
    # If it's thundering, cut the population in half again
    if (defined $city->{'weather'}->{'thunder'} ) {
        $visiblepop=ceil($visiblepop/2);
    }
    # Finally, if it's not nice out, cut the population even further.
    $visiblepop=ceil($visiblepop*$city->{'weather'}->{'tempmodifier'});

    $city->{'visiblepopulation'}=$visiblepop;
}
###############################################################################
#
# generate_weather - set the weather, which determines visible population
#
###############################################################################
sub generate_weather {
    $city->{'weather'} ={};
    $city->{'weather'}->{'forecast'} = rand_from_array( $xml_data->{'weather'}->{'forecast'}->{'option'} )->{'content'};
    my $temp = rand_from_array( $xml_data->{'weather'}->{'temp'}->{'option'} );
    $city->{'weather'}->{'tempmodifier'}=$temp->{'modifier'};
    $city->{'weather'}->{'temp'}=$temp->{'content'};

    $city->{'weather'}->{'air'} = rand_from_array( $xml_data->{'weather'}->{'air'}->{'option'} )->{'content'};
    $city->{'weather'}->{'wind'} = rand_from_array( $xml_data->{'weather'}->{'wind'}->{'option'} )->{'content'};
    $city->{'weather'}->{'clouds'} = rand_from_array( $xml_data->{'weather'}->{'clouds'}->{'option'} )->{'content'};
    if (&d(100) <= $xml_data->{'weather'}->{'thunder'}->{'chance'}){
        $city->{'weather'}->{'thunder'} = rand_from_array( $xml_data->{'weather'}->{'thunder'}->{'option'} )->{'content'};
    }
    if (&d(100) <= $xml_data->{'weather'}->{'precip'}->{'chance'}){
        my $precip = rand_from_array( $xml_data->{'weather'}->{'precip'}->{'option'} );
        $city->{'weather'}->{'precip'}= $precip->{'description'};
        if (defined $precip->{'type'} ){
            $city->{'weather'}->{'precip'} = (rand_from_array( $precip->{'type'} )->{'content'}||"it's ") . $city->{'weather'}->{'precip'} ;

        }
    }
}

###############################################################################
#
# generate_time - set the current time, which determines visible population
#
###############################################################################
sub generate_time {
    $city->{'time'} = rand_from_array( $xml_data->{'time'}->{'option'} );
}


###############################################################################
#
# generate_education_description - generate the economic description
#
###############################################################################
sub generate_education_description {
    my $educationtype     = roll_from_array( $city->{'education'}, $xml_data->{'educationalignment'}->{'option'} );
    my $adjective     = rand_from_array( $educationtype->{'adjective'} )->{'content'};
    $city->{'educationdescription'}=$adjective;
}

###############################################################################
#
# generate_magic_description - generate the economic description
#
###############################################################################
sub generate_magic_description {
    my $magictype     = roll_from_array( $city->{'magic'}, $xml_data->{'magicalignment'}->{'option'} );
    my $adjective     = rand_from_array( $magictype->{'adjective'} )->{'content'};
    $city->{'magicdescription'}=$adjective;
}

###############################################################################
#
# generate_economic_description - generate the economic description
#
###############################################################################
sub generate_economic_description {
    my $econtype     = roll_from_array( $city->{'economy'}, $xml_data->{'economyalignment'}->{'option'} );
    my $adjective     = rand_from_array( $econtype->{'adjective'} )->{'content'};
    $city->{'economydescription'}=$adjective;
}

###############################################################################
#
# generate_travelers - generate a few travelers
#
###############################################################################
sub generate_travelers{
    my $travelercount= int( ( 6 +  $city->{'size_modifier'} )/2);
    $city->{'travelers'}=[];
    while ($travelercount-- ){
        $seed++;
        #TODO switch to roll_from_array
        my $travelerclass= rand_from_array( [ keys %{$xml_data->{'classes'}->{'class'}}] );
        my $traveler=$xml_data->{'classes'}->{'class'}->{$travelerclass};
        $traveler->{'class'}=$travelerclass;
        $traveler->{'level'}= min( 20 ,max(1, &d($traveler->{'max_level'}) + &d( $city->{'size_modifier'} )) ) ;
        if ( &d(20) > 5 ){
            my @races=shuffle get_races(   $city->{'base_pop'}   );
            $traveler->{'race'}  =pop( @races  );
            $traveler->{'reaction'}='oblivious';
        }else{
            $traveler->{'race'}  =get_other_race(  $city->{'base_pop'} );
            $traveler->{'reaction'}='untrusting';
        }
        my $names=generate_npc_name(  $traveler->{'race'}->{'content'}  );

        foreach my $nametype (qw/ firstname lastname fullname noname sex/ ){
            if (defined $names->{$nametype}){
                $traveler->{$nametype}= $names->{$nametype};
            }
        }
        my $motivation=rand_from_array($xml_data->{'travelermotivation'}->{'motive'});
        if (defined $motivation->{'option'}){
            $traveler->{'motivation'}=$motivation->{'type'}." ".rand_from_array($motivation->{'option'})->{'content'};
        }else{
            $traveler->{'motivation'}=$motivation->{'type'};
        }
        push @{$city->{'travelers'}}, $traveler;

    }
    set_seed($originalseed);
}
###############################################################################
#
# generate_taverns - generate a few taverns;
#
###############################################################################

sub generate_taverns{
    my $taverncount=0;
    if (defined $city->{'business'}->{'tavern/inn'}){
        $taverncount+=$city->{'business'}->{'tavern/inn'}->{'count'};
    }
    $taverncount=min(5 ,  $taverncount);
    $city->{'taverns'}=[];
    while ($taverncount-- > 0){
        $seed++;
        my $tavern->{'name'}= parse_object($xml_data->{'taverns'} )->{'content'};
        $tavern->{'cost'}=$city->{'economy'};
        $tavern->{'population'}=0;

        $tavern->{'size'}=rand_from_array( $xml_data->{'taverns'}->{'size'}   );
        $tavern->{'cost'}+=$tavern->{'size'}->{'cost_mod'};
        $tavern->{'population'}+=$tavern->{'size'}->{'pop_mod'};
        $tavern->{'size'}=$tavern->{'size'}->{'content'};

        $tavern->{'condition'}=rand_from_array( $xml_data->{'taverns'}->{'condition'}   );
        $tavern->{'cost'}+=$tavern->{'condition'}->{'cost_mod'};
        $tavern->{'condition'}=$tavern->{'condition'}->{'content'};

        $tavern->{'class'}=roll_from_array( &d(100),$xml_data->{'taverns'}->{'class'}   );
        $tavern->{'cost'}+=max(-5,min(5,$tavern->{'class'}->{'cost_mod'}));
        $tavern->{'class'}=$tavern->{'class'}->{'content'};

        $tavern->{'violence'}=rand_from_array( $xml_data->{'taverns'}->{'violence'}   )->{'content'};
        $tavern->{'legal'}=rand_from_array( $xml_data->{'taverns'}->{'legal'}   )->{'content'};

        $tavern->{'costdescription'}=roll_from_array( $tavern->{'cost'}, $xml_data->{'taverns'}->{'cost'}   )->{'content'};
        $tavern->{'bartender'}=generate_bartender();

        push @{$city->{'taverns'}}, $tavern;
    }
    set_seed($originalseed);
}

###############################################################################
#
# generate_bartender - generate a bartender
#
###############################################################################
sub generate_bartender{

    my $bartender;
    $bartender->{'behavior'}=rand_from_array( $xml_data->{'behavioraltraits'}->{'trait'} )->{'type'};
    my @races=get_races(   $city->{'base_pop'}    );
    $bartender->{'race'}= pop(@races) ;
    $bartender->{'level'}= min( 20 ,max(1, &d("3d4")+ &d( $city->{'size_modifier'} )) ) ;

    my $names=generate_npc_name(  $bartender->{'race'}->{'content'}  );

    foreach my $nametype (qw/ firstname lastname fullname noname/ ){
        if (defined $names->{$nametype}){
            $bartender->{$nametype}= $names->{$nametype};
        }
    }

    return $bartender;
}




###############################################################################
#
# generate_npc_name - generate an npc name if they're available for that race
#
###############################################################################

sub generate_npc_name{
    my($race)=@_;
    # ensure it's lowercase
    my $npc;

print Dumper $race;
    #check to see if there is a "half-elf section in the names_data"
    if (! defined $names_data->{'race'}->{ $race} ){
        #half-elves don't exist, in the names_data file, so lets see if a names option exists.
        if (defined $xml_data->{'nameoptions'}->{'race'}->{$race}){
print Dumper  $xml_data->{'nameoptions'}->{'race'}->{$race};
            #if it does, steal a random race option from here and use it.
            $race= rand_from_array( $xml_data->{'nameoptions'}->{'race'}->{$race}->{'option'})->{'content'};
        }
    }


    $race= lc $race;
    if (defined $names_data->{'race'}->{ $race}     ){
        my $racenames=$names_data->{'race'}->{ $race} ;
        if ( defined $racenames->{'firstname'} ){
            $npc->{'firstname'}= parse_object(    $racenames->{'firstname'}         )->{'content'};
            if ($npc->{'firstname'} ne ''){
                $npc->{'fullname'}=$npc->{'firstname'};
            }
        }
        if ( defined $racenames->{'lastname'} ){
            $npc->{'lastname'}= parse_object(    $racenames->{'lastname'}         )->{'content'};
            if ($npc->{'lastname'} ne ''){
                $npc->{'fullname'}=$npc->{'lastname'};
            }
        }
        if ( defined $npc->{'firstname'} and defined $npc->{'lastname'} and $npc->{'firstname'} ne '' and $npc->{'lastname'} ne '' ){
            $npc->{'fullname'}=$npc->{'firstname'} ." ". $npc->{'lastname'};
        }
    }else{
        $npc->{'noname'}="random $race";
    }


    $npc->{'sex'}= roll_from_array( &d(100),    $xml_data->{'sex'}->{'option'}    );

    return $npc;
}

###############################################################################
#
# generate_resources - select resources modified by city size.
#
###############################################################################

sub generate_resources{
    #ensure that the resource count is at most 13 and at least 2
    my $resource_count=min( max($city->{'size_modifier'}+$city->{'economy'}, 2 ),13) ;
    #shift from 2-13 to 1-12
    $city->{'resourcecountb'}= $resource_count;
    $resource_count = &d($resource_count);
    $city->{'resourcecount'}= $resource_count;

    $city->{'resources'}=[];
    while ($resource_count-- > 0 ){
        $seed++;
        my $resource=rand_from_array($xml_data->{'resources'}->{'resource'});
        push @{ $city->{'resources'} }, parse_object($resource);
    }

    set_seed($originalseed);
}


###############################################################################
#
# generate_markets - select some markets according to their chance of 
# appearance modified by city size.
#
###############################################################################
sub generate_markets {

    $city->{'markets'}=[];
    # minimum of 2 markets, max of size modifier(9)
    my $marketcount= max(2, &d( int(6 + $city->{'size_modifier'})/2     ));


    # loop through the marketcount to randomly select markets
    # this allows us to get "duplicates"
    my $tries=scalar( @{ $xml_data->{'markets'}->{'option'} })*2;
    while ( $marketcount > 0 and $tries-- >0){
        $seed++;
        # get a shuffled list of markets
        my @markets=shuffle @{ $xml_data->{'markets'}->{'option'} };

        #pop a single market off
        my $market = pop  @markets ;

        # modify the chance of the market by the size modifier
        my $chance_of_market= $market->{'chance'} +  $city->{'size_modifier'};

        # if we succeed, decrement the marketcount and push the market to 
        # our queue
        if (&d(100) <= $chance_of_market){
            $marketcount--;
            my $newmarket={ 
                                'type'=> $market->{'type'}, 
                                'name'=> $market->{'marketname'}.' '.$market->{'type'}
                            };
            # set market secret
            if ( &d(100) <$market->{'secret'} ){
                $newmarket->{'secret'}='secret ';
            }else{
                $newmarket->{'secret'}='';
            }

            # select market detail
            if ( &d(100) > 50 ){
                my $marketoption=rand_from_array($market->{'option'});
                $newmarket->{'name'}=  $newmarket->{'secret'}. $marketoption->{'content'}.' '.$newmarket->{'name'};
            }

            # push it to the queue
            push @{$city->{'markets'}}, $newmarket;

       } 

    }
    set_seed($originalseed);
}








###############################################################################
#
# generate_realm - Determine the realm of the city
#
###############################################################################
sub generate_realm {
    set_seed($originalseed-$originalseed%10);
    $city->{'realm'}=parse_object($xml_data->{'realm'})->{'content'};
    set_seed($originalseed);
}


###############################################################################
#
# generate_Continent - Determine the name of the Continent
#
###############################################################################
sub generate_continent {
    set_seed($originalseed-$originalseed%100);
    $city->{'continent'}=parse_object($xml_data->{'continent'})->{'content'};
    set_seed($originalseed);
}

###############################################################################
#
# generate_climate - Determine the climate of the city
#
###############################################################################
sub generate_climate {
    $city->{'climate'}=rand_from_array($xml_data->{'climate'}->{'option'});
}


###############################################################################
#
# generate_topography - Determine information about the neighbors. 
#
###############################################################################
sub generate_topography {
    $city->{'topography'}=rand_from_array($xml_data->{'topography'}->{'region'})->{'content'};
}

###############################################################################
#
# generate_neighbors - Determine information about the neighbors. 
#
###############################################################################

sub generate_neighbors {

    #FIXME since set_ctiy_size acts on the global city, we temporarily switch origcity and city around
    # This is a hack, but it works.
    my $origcity=$city;
    my $continentseed=$originalseed-$originalseed%100;
    for (my $i = 0 ; $i < 100; $i++){
        my $neighborid=$continentseed+$i;

        set_seed($neighborid);
        $city={}; 
        $city->{'id'}=$neighborid;
        $city->{'name'}= parse_object($xml_data->{'cityname'})->{'content'};
        set_city_size();
        set_city_type();
        generate_pop_type();
        assign_races();
#        generate_pop_counts();
        # Setting seed=neighborid+oldseed will guarantee the same relationship between A and B
       my $mixseed=$neighborid+$originalseed;
        set_seed($mixseed);
        $city->{'relation'} =" $neighborid + $originalseed  = $seed  " .rand_from_array(  $xml_data->{'neighbor'}->{'relation'}  )->{'content'};

        push @{$origcity->{'neighbors'}}, $city;
    }
    set_seed($originalseed);
    $city=$origcity
}


###############################################################################
#
# generate_walls - Determine information about the streets. 
#
###############################################################################
sub generate_walls {
    #Chance of there being a wall
    my $roll=&d(20)+ $city->{'size_modifier'} ;

    if( $xml_data->{'walls'}->{'chance'}< $roll){
        my $wallroll=&d(100) + $city->{'size_modifier'};
        my $wall=roll_from_array( $wallroll, $xml_data->{'walls'}->{'wall'}     );
        $city->{'walls'}=parse_object($wall);
        $city->{'walls'}->{'height'}= $wall->{'heightmin'}+  &d($wall->{'heightmax'}-$wall->{'heightmin'})   + $city->{'size_modifier'};

    }else{
        $city->{'walls'}->{'content'}="none";
        $city->{'walls'}->{'height'}=0;
    }
}

###############################################################################
#
# generate_streets - Determine information about the streets. 
#
###############################################################################
sub generate_streets {
    $city->{'streets'}=parse_object($xml_data->{'streets'});

    $city->{'streets'}->{'mainroads'}=max(0,   int(($city->{'travel'}+$city->{'economy'})/3)  );
    $city->{'streets'}->{'roads'}=max(1,   int(($city->{'travel'}+$city->{'economy'})/3) + $city->{'streets'}->{'mainroads'}  );


}

sub adjust_chance_for_port{
    if ( $city->{'location'}->{'port'}  ) {
        $xml_data->{'districts'}->{'district'}->{'port'}->{'chance'}=80;
    }
}
sub specialists_influence_districts{

    foreach my $business (@{$city->{'buildings'}}){
        my $district=$city->{'business'}->{$business->{'content'}}->{'district'};
        $xml_data->{'districts'}->{'district'}->{$district}->{'chance'}+= $city->{'business'}->{$business->{'content'}}->{'specialists'} ;
    }

}

###############################################################################
#
# generate_districts - using population size and professionals, determine
# the most likely districts.
#
###############################################################################
sub generate_districts {

    $city->{'districts'}=[];

    adjust_chance_for_port();

    # use the number of specialists to influence the chance of a district showing up
    specialists_influence_districts();

    # select a number of districts using the size modifier of the city and order of cirt
    # larger city or more order means more districts, generally speaking.
    my $districtcount=5 + int((6+$city->{'size_modifier'}) /3)  +       (int($city->{'order'}/10) -5)  ;

    # keep it in the city object for posterity.
    $city->{'districtcount'}= $districtcount;

    # get a list of all of the districts we have available
    my @districtlist=shuffle keys %{$xml_data->{'districts'}->{'district'}};

    # Number of times we're allowed to fail before drastic actions are taken
    # This allows us to still use both district counts and district chance
    # before making both useless
    my $failallowance=scalar(@districtlist);

    # If we fail, the kludge facter will increase...
    my $kludge=0;

    # Keep looping until we have all of our districts allocated.
    while ($districtcount >0){ 

        # grab top district and its stats
        my $districtname=pop @districtlist;
        my $district=$xml_data->{'districts'}->{'district'}->{$districtname};
        my $districtchance=$district->{'chance'}  + $city->{'size_modifier'}*2 + $city->{$district->{'stat'}} + $kludge;

        # check to see if we can add the district
        if (&d(100) <= $districtchance ){
            # success! add it to the list, reset kludge to 0 (if it was used) and decrement the districtcount
            push @{$city->{'districts'}}, $districtname;
            $kludge=0;
            $districtcount--;
        }else{
            # We failed to assign this distict. put it at the back of the line and
            # decrement our fail allowance
            unshift @districtlist, $districtname;
            $failallowance--;
        }
        # We've reached critical failure!
        if ($failallowance <= 0 ){
            # Reset the fail allowance and bump up the kludge 25%
            # This allows us to incrementally reduce failure and still value relative chance
            $failallowance =scalar ( keys %{$xml_data->{'districts'}->{'district'}});
            $kludge+=25;
            #print "failed , forcing kludge of $kludge% to checks\n";
        }

    }

}

###############################################################################
#
# generate_business - using population size and professionals, determine
# the most likely districts.
#
###############################################################################
sub generate_businesses{

    $city->{'business'}={};
    $city->{'businesstotal'}=0;
    #5.5-10.5%  of the population runs a business, depending on the economy
    my $businessestimate=floor($city->{'population'}->{'size'}*(15+($city->{'economy'}+$city->{'size_modifier'} ))/100 );
    $city->{'business'}={ 'estimate'=>$businessestimate };

    # separate each business into priorities
    my $businesspriorities={};

    # Loop throuch each type of building
    for my $business (  @{ $xml_data->{'buildings'}->{'building'} }   ){
        #Note that we're sortiny by priority.
        my $priority= $business->{'priority'};
        if (!defined $businesspriorities->{$priority}){
            $businesspriorities->{$priority}=[];
        }

        #we want to flesh this out according to weight.        
        while ( $business->{'weight'} >0 ){
            my %business2=%$business;
            push @{$businesspriorities->{$priority}}, \%business2;

            $business->{'weight'}--;
        }
    }
    my %junkpriority=%$businesspriorities;
    my @weightedbusinesses;
    foreach my $priority (sort { $a <=> $b } keys %junkpriority){
        push @weightedbusinesses, @{$junkpriority{$priority}};
        while ($city->{'business'}->{'estimate'}>0) {
            if (@{$junkpriority{$priority}} >=1){
                my @businesses=shuffle @{$junkpriority{$priority}};
                my $newbusiness=pop @businesses;
                if (  $city->{'size_modifier'}  >=   $newbusiness->{'requires_size'}  ){
                    if (!defined $city->{'business'}->{$newbusiness->{'content'}}){
                        $city->{'business'}->{$newbusiness->{'content'}}={'specialists'=>1} ;
                        $city->{'business'}->{$newbusiness->{'content'}}->{'perbuilding'}=$newbusiness->{'perbuilding'};
                        $city->{'business'}->{$newbusiness->{'content'}}->{'weight'}     =$newbusiness->{'weight'};
                        $city->{'business'}->{$newbusiness->{'content'}}->{'priority'}   =$newbusiness->{'priority'};
                        $city->{'business'}->{$newbusiness->{'content'}}->{'requires_size'}   =$newbusiness->{'requires_size'};
                        $city->{'business'}->{$newbusiness->{'content'}}->{'profession'}   =$newbusiness->{'profession'}||undef;
                    }else{
                        $city->{'business'}->{$newbusiness->{'content'}}->{'specialists'}++;
                    }
                }
                $city->{'business'}->{'estimate'}--;
                $junkpriority{$priority}=\@businesses;
            }else{
                last;
            }
        }
    }
    @weightedbusinesses=shuffle @weightedbusinesses;
    while ($city->{'business'}->{'estimate'}>0) {

        @weightedbusinesses=shuffle @weightedbusinesses;
        my $newbusiness=$weightedbusinesses[0];
        # To show, an alchemist (0), the modifier must be 0 or greater
        if (  $city->{'size_modifier'}  >=   $newbusiness->{'requires_size'}  ){
            if (!defined $city->{'business'}->{$newbusiness->{'content'}}){
                #print Dumper $newbusiness->{'district'};
                $city->{'business'}->{$newbusiness->{'content'}}={'specialists'=>1};
            }else{
                $city->{'business'}->{$newbusiness->{'content'}}->{'specialists'}++;
                    $city->{'business'}->{$newbusiness->{'content'}}->{'district'}=$newbusiness->{'district'};
            }
            $city->{'business'}->{'estimate'}--;
        }
    }
        delete $city->{'business'}->{'estimate'};
    $city->{'specialisttotal'} =0;
    foreach my $businessname (keys %{$city->{'business'}}){
#        print Dumper $city->{'business'}->{$businessname};
        $city->{'business'}->{$businessname}->{'count'}=ceil( $city->{'business'}->{$businessname}->{'specialists'} /$city->{'business'}->{$businessname}->{'perbuilding'});
        $city->{'businesstotal'}+=$city->{'business'}->{$businessname}->{'count'};
        $city->{'specialisttotal'}+=$city->{'business'}->{$businessname}->{'specialists'};
    }


}


###############################################################################
#
# generate_support_area - using population size, determine the size of the
# area needed to support the city. results is in square miles.
#
###############################################################################
sub generate_support_area {
    # Population * (feet per person - sizemodifier*10 ) =total feet per population adjusted for city size
    # low fpp = successful
    # a good economy,education, magic and law increases production by  5+5+50+5 36%
    # ranges from 5+5+50+50=+110=290 to -5-5-50+0=-60 =0
    # base+ed+econ + (order-50) + magic= 290 people per sqmile
    # base+ed+econ + (order-50) + magic= 0 people per sqmile
    # a desert with no economy, no education, no magic and no order can't support anyone.

    my $people_per_sq_mile= $city->{'climate'}->{'pop_support'}+ $city->{'economy'} + $city->{'education'} + ($city->{'order'}-50) +  ($city->{'magic'}+5)*5 ;
    $city->{'supportarea'}=   int($city->{'population'}->{'size'}/$people_per_sq_mile *100*258.999  )/100;
}



###############################################################################
#
# generate_area - using population size and density, determine the size of 
# the city. results is in hectares.
#
###############################################################################
sub generate_area {
    # Population * (feet per person - sizemodifier*10 ) =total feet per population adjusted for city size
    $city->{'area'}=   int( $city->{'population'}->{'size'}*( $city->{'popdensity'}->{'feetpercapita'}-$city->{'size_modifier'}*10   ) /107639*100 )/100; #hectares;

}

###############################################################################
#
# generate_housing - generate the types of housing and how much there is.
#
###############################################################################
sub generate_housing {
    $city->{'housing'}={};

    my @qualitylist= keys %{ $xml_data->{'housing'}->{'quality'}};

    $xml_data->{'housing'}->{'quality'}->{'poor'}->{'percent'}-=($city->{'economy'}*5);

    $xml_data->{'housing'}->{'quality'}->{'average'}->{'percent'}+=($city->{'economy'}*5);


    $city->{'population'}->{'wealthy'}=ceil( $city->{'population'}->{'size'} * $xml_data->{'housing'}->{'quality'}->{'wealthy'}->{'percent'}/100 );
    $city->{'population'}->{'average'}=ceil( $city->{'population'}->{'size'} * $xml_data->{'housing'}->{'quality'}->{'average'}->{'percent'}/100 );
    $city->{'population'}->{'poor'}= $city->{'population'}->{'size'} - $city->{'population'}->{'average'} - $city->{'population'}->{'wealthy'} ;

    foreach my $housingquality ( @qualitylist ){

        my $housingtype= $xml_data->{'housing'}->{'quality'}->{$housingquality};

        # fractional housecount total, but you can't have .3 of a house... 
        my $housecount= $city->{'population'}->{'size'}  *   $housingtype->{'percent'}/$housingtype->{'density'}/100;

        # to ensure minimal housing, we require poor housing via ceil, so we always have 1.
        if (defined $housingtype->{'required'}){
            $city->{'housing'}->{$housingquality}        = ceil ($housecount); # ceil used because we want at least 1 poor house
        }else{
            $city->{'housing'}->{$housingquality}        = floor ($housecount);
        }
        $city->{'housing'}->{'total'}+=$city->{'housing'}->{$housingquality}

    }

    # Calculate abandoned by finding 11% of total and adjusting it by economy conditions (+/-10%), min of 1
    $city->{'housing'}->{'abandoned'}   = ceil($city->{'housing'}->{'total'} *(11-($city->{'economy'})*2 )/100 );

}

###############################################################################
#
# generate_location - select the location we wish to use and any landmarks.
#
###############################################################################


sub generate_location {
    $city->{'location'} = { 'landmarks'=>[]  };
    my $locationlist=$xml_data->{'locations'}->{'location'};

    my $location = rand_from_array(  $locationlist  );
    $city->{'location'}->{'name'}=$location->{'description'};
    $city->{'location'}->{'port'}= ( &d(100) <= $location->{'port_chance'}  );
    $city->{'location'}->{'coastdirection'}=rand_from_array($xml_data->{'direction'}->{'option'})->{'content'};
    #why 20? to give us a better chance of getting one.
    my $landmarkmod=20;
    foreach my $landmark (shuffle @{$location->{'landmarks'}}){
        if (&d(100) <= $landmark->{'chance'}+$landmarkmod){
            push @{$city->{'location'}->{'landmarks'}},  $landmark->{'content'};
            $landmarkmod-=5;
        }
    }
}


sub generate_crime{
    #higher means more crime
    # random -education + authority averaged with reversed morality.
    # low morality= high reversed morality, which raises the average
    my $crime_roll= int((&d(100) + $city->{'education'} - $city->{'authority'} + ( 100 - $city->{'moral'}) )/2);

    $city->{'crime'}= roll_from_array($crime_roll, $xml_data->{'crime'}->{'option'});
    $city->{'crime'}->{'roll'}=$crime_roll;

}

###############################################################################
#
# generate_imprisonment_rate - city size, authority, order and education
# determine what percentage of the city is in jail. 0.05% to  01.815%
#
###############################################################################

sub generate_imprisonment_rate{
    # should range from ((15-5-5-5)*.5/5+1).5/10=.05% to ((15+5+5+12)*1.5/5+1)/10=1.815
    # high authority means more in jail
    # low education means more in jail
    # larger city means more in jail
    # higher order means more in jail
    $city->{'population'}->{'imprisonment'}={};
    $city->{'population'}->{'imprisonment'}->{'percent'} = (((15 + $city->{'authority'} - $city->{'education'}  +$city->{'size_modifier'} )/5) +1 )*($city->{'order'}+50)/100 /10 ;

    #calculate out the actual prison population in whole numbers
    $city->{'population'}->{'imprisonment'}->{'population'}= ceil( $city->{'population'}->{'imprisonment'}->{'percent'}/100 * $city->{'population'}->{'size'});

    #recalulate to make the percent accurate with the population
    $city->{'population'}->{'imprisonment'}->{'percent'}= int($city->{'population'}->{'imprisonment'}->{'population'}/$city->{'population'}->{'size'}*1000)/10;


}



###############################################################################
#
# generate_elderly - set the percentage of the population that are elderly, 
# modified by the age of the city
#
###############################################################################
sub generate_elderly {

    $city->{'population'}->{'elderly'}={};
    #calculate the pop based on 10 +random factor - city age modifier; should give us a rage between
    # 1% and 26%, which follows the reported international rates of the US census bureau, so STFU.
    $city->{'population'}->{'elderly'}->{'percent'}= max(1.5, (6 + &d(5) -  $city->{'cityage'}->{'agemod'})  );

    #calculate out the actual child population in whole numbers
    $city->{'population'}->{'elderly'}->{'population'}= ceil( $city->{'population'}->{'elderly'}->{'percent'}/100 * $city->{'population'}->{'size'});

    #recalulate to make the percent accurate with the population
    $city->{'population'}->{'elderly'}->{'percent'}= ceil($city->{'population'}->{'elderly'}->{'population'}/$city->{'population'}->{'size'}*1000)/10;

}


###############################################################################
#
# generate_children - set the percentage of the population that are children, 
# modified by the age of the city
#
###############################################################################
sub generate_children {

    $city->{'population'}->{'children'}={};
    #calculate the pop based on 20 +random factor + city age modifier; should give us a rage between
    # 10% and 45%, which follows the reported international rates of the US census bureau, so STFU.
    $city->{'population'}->{'children'}->{'percent'}= 20 + &d(15) +  $city->{'cityage'}->{'agemod'};

    #calculate out the actual child population in whole numbers
    $city->{'population'}->{'children'}->{'population'}= floor( $city->{'population'}->{'children'}->{'percent'}/100 * $city->{'population'}->{'size'});

    #recalulate to make the percent accurate with the population
    $city->{'population'}->{'children'}->{'percent'}= int($city->{'population'}->{'children'}->{'population'}/$city->{'population'}->{'size'}*1000)/10;

}


###############################################################################
#
# generate_city_age - a simple selector
#
###############################################################################
sub generate_city_age {
    my $agelist=$xml_data->{'cityages'}->{'cityage'};

    $city->{'cityage'}= rand_from_array(  $agelist  );
}


###############################################################################
#
# Generate Secondary Power - select a plot, a power and a subplot.
#
###############################################################################
sub generate_secondary_power {
    $city->{'secondarypower'}={};

    # select a plot
    my $plotlist=$xml_data->{'secondarypower'}->{'plot'};
    $city->{'secondarypower'}->{'plot'} = rand_from_array( $plotlist )->{'content'};

    #select a power and a related subplot.
    my $powerlist=$xml_data->{'secondarypower'}->{'power'} ;
    my $power = rand_from_array(  $powerlist );
    $city->{'secondarypower'}->{'power'} = rand_from_array(  $powerlist )->{'type'};
    if ( &d(100) <= $power->{'subplot_chance'} ){
        $city->{'secondarypower'}->{'subplot'} = rand_from_array(  $power->{'subplot'}  )->{'content'};
    }
}


###############################################################################
#
# set_govt_type - fairly simple; select a type of govt from the list.
#
###############################################################################
sub set_govt_type {
    my $govttypelist=$xml_data->{'govtypes'}->{'govt'} ;
    $city->{'govtype'} = rand_from_array(  $govttypelist  );

    my $respectlist=$xml_data->{'respect'}->{'option'} ;
    my $respect = rand_from_array(  $respectlist  );
    $city->{'govtype'}->{'respect'}=$respect->{'content'};

    # add random element + govtype base approval_mod + respect approval + authority mod
    $city->{'govtype'}->{'approval_mod'}    = &d(4)-2 +  $city->{'govtype'}->{'approval_mod'} + $respect->{'approval_mod'} +  $city->{'authority'};

    # ensure it falls in the proper range
    $city->{'govtype'}->{'approval_mod'}=max(-5, min(5,  $city->{'govtype'}->{'approval_mod'}   ) );

    $city->{'govtype'}->{'religion'}=&d(4)-2 +  $city->{'govtype'}->{'religion'} ; 

    $city->{'govtype'}->{'mil_mod'}=  $city->{'govtype'}->{'mil_mod'} ; 

    my $order=roll_from_array( $city->{'order'}, $xml_data->{'orderalignment'}->{'option'}   );
    $city->{'govtype'}->{'orderalignment'}= rand_from_array($order->{'adjective'})->{'content'};



}



###############################################################################
#
# Set Laws - Laws have three facets- enforcement, trial and punishment. 
# Select these from arrays.
#
###############################################################################

sub set_laws {
    $city->{'laws'} = {};
    for my $facet (qw( enforcement trial punishment enforcer commoncrime)) {
        my $facetlist=$xml_data->{'laws'}->{$facet}->{'option'};
        $city->{'laws'}->{$facet} = rand_from_array(  $facetlist  )->{'content'};
    }
}



###############################################################################
#
# generate_city_ethics - Intended for morals and order (classic alignment).
#
###############################################################################
sub generate_city_ethics {
    foreach my $mod ( qw/ moral order/ ) {
        $city->{$mod} = &d(100);
        # adjust all modifiers for each race
        for my $race ( @{ $city->{'races'} } ) {
            $city->{$mod} += $race->{$mod};
        }
        # Use min/max to ensure that we fall in the proper ranges when all is said and done        
        $city->{$mod}=max(1, min(100, $city->{$mod} ) );
        # choose a description
        my $description=roll_from_array( $city->{$mod} , $xml_data->{$mod.'alignment'}->{'option'});
        $city->{$mod."description"}=rand_from_array( $description->{'adjective'})->{'content'};
    }
}
###############################################################################
#
# generate_city_beliefs - This includes other scales, such as determining if 
# the city is a trade hub, etc. 
#
###############################################################################
sub generate_city_beliefs {

    # set the baseline random modifier
    foreach my $mod (qw/ magic authority economy education travel tolerance military / ){
        $city->{$mod} =&d(4)-2;
        # adjust all modifiers for each race
        for my $race ( @{ $city->{'races'} } ) {
            $city->{$mod} += $race->{$mod};
        }

        # Use min/max to ensure that we fall in the proper ranges when all is said and done        
        $city->{$mod} = max(-5, min(5, $city->{$mod} ) );
        my $description=roll_from_array( $city->{$mod} , $xml_data->{$mod.'alignment'}->{'option'});
        $city->{$mod."description"}=rand_from_array( $description->{'adjective'})->{'content'};
    }


}

###############################################################################
#
# generate_population_counts - for each race percentage. After getting 
# population counts, recalulate total population, then final percentages.
# note that actual races are not yet associated.
#
###############################################################################
sub generate_pop_counts {
    my $population = $city->{'population'}->{'size'};
    my $newpop     = 0;
    my @races;
    my @newraces;

    # Loop through each race percentage, and get a rough count based
    # on population total
    for my $race ( sort @{ $city->{'races'} } ) {
        $race->{'count'} = ceil( $population * $race->{'percent'} / 100 );
        $newpop += $race->{'count'};
        push @races, $race;
    }

    # Add up all of the rough counts to create a final population total
    $city->{'population'}->{'size'} = $newpop;
    $city->{'races'}      = \@races;

    # Loop through the races a second time, recalulating percentages.
    for my $race ( sort @{ $city->{'races'} } ) {
        $race->{'percent'} = int( $race->{'count'} / $newpop * 1000 ) / 10;
        push @newraces, $race;
    }
    $city->{'races'} = \@newraces;
}


###############################################################################
#
# Assign races. This consists of 
#   * looking at the base population type to gather available base races 
#   * looping through the race percentages and assigning an available race
#   * adding an "off race" if applicable.
#   * adding 1% other    
#
###############################################################################
sub assign_races {
    my $base_pop        = $city->{'base_pop'};
    my @races;

    # Get all of the available race options
    my @available_races = get_races($base_pop);

    # for each race percentage on the city,
    # add assign a race and add it to the list.
    for my $racepercentage ( @{ $city->{'races'} } ) {
        my $newrace = pop(@available_races);
        push @races, add_race_features( $racepercentage, $newrace );
    }


    # If the base_pop has an "off" race, add it.
    if ( $city->{'add_other'} eq 'true' ) {
        my $newrace              = get_other_race($base_pop);
        my $replace_race_id      = &d( scalar @races ) - 1;
        $races[$replace_race_id] = add_race_features( $races[$replace_race_id], $newrace );
    }

    # add the last percent of "others" because mrsassypants didn't grok that
    # things added up to 99% for a reason.
    push @races,add_race_features( {'percent'=>'1'}, get_races('other'));
    for my $race ( @races ) {
        $seed++;
        my $roll= &d(10)-5 + $race->{'tolerance'} ;
        my $tolerancetype = roll_from_array( $roll , $xml_data->{'tolerancealignment'}->{'option'} );
        $race->{'tolerancedescription'}= rand_from_array( $tolerancetype->{'adjective'})->{'content'};
    }
    #replace race percentages with full race breakdowns.
    $city->{'races'} = \@races;
    set_seed($originalseed);
}


###############################################################################
#
# add_race_features - copy the features over for a given races. Effectively
# merges percent onto the race.
#
###############################################################################

sub add_race_features {
    my ( $race, $newrace ) = @_;
    $race->{'content'}   = $newrace->{'content'};
    $race->{'order'}     = $newrace->{'order'};
    $race->{'moral'}     = $newrace->{'moral'};
    $race->{'magic'}     = $newrace->{'magic'};
    $race->{'authority'} = $newrace->{'auth'};
    $race->{'economy'}   = $newrace->{'econ'};
    $race->{'education'} = $newrace->{'edu'};
    $race->{'travel'}    = $newrace->{'travel'};
    $race->{'military'}    = $newrace->{'mil'};
    $race->{'tolerance'} = $newrace->{'toler'};
    $race->{'plural'}    = $newrace->{'plural'};
    $race->{'type'}      = $newrace->{'type'};
    $race->{'article'}   = $newrace->{'article'};

    if (defined $race->{'dominant'} ){
        $city->{'dominant_race'}  =  $newrace->{'content'};
    }
    return $race;
}



###############################################################################
#
# get races - get the races that match the given population type.
# If the type is mixed, add the race as long as it's not an other race.
#
###############################################################################

sub get_races {
    my ( $type ) = @_;
    my @races;
    for my $race ( @{ $xml_data->{'races'}->{'race'} } ) {
        if (   ($race->{'type'} eq $type)  or   (($type eq 'mixed') and  ($race->{'type'} ne 'other')) ) {
            push @races, $race;
        }
    }
    return shuffle @races;
} 

###############################################################################
#
# get_other_race - get the races that doesn't match the given population type.
# make sure to exclude other.
#
###############################################################################

sub get_other_race {
    my ($type) = @_;
    my @races;
    for my $race ( shuffle @{ $xml_data->{'races'}->{'race'} } ) {
        if ( $race->{'type'} ne $type  and   ($race->{'type'} ne 'other') ) {
            return $race;
        }
    }
} 

###############################################################################
#
# Generate a Population Type, then populate the population type, population 
# density, and a list of unassigned race percentages.
#
###############################################################################
sub generate_pop_type {
    my $poptype     = roll_from_array( &d(100), $xml_data->{'poptypes'}->{'population'} );
    my $popdensity  = rand_from_array( $xml_data->{'popdensity'}->{'option'} );

    $city->{'popdensity'}   = $popdensity;
    $city->{'poptype'}      = $poptype->{'type'};
    $city->{'races'}        = $poptype->{'option'};
}


###############################################################################
#
# set_city_type - Find the type of city by selecting it from the citytype list,
# Then populate the base population, type, description and whether 
# or not it's a mixed city.
#
###############################################################################
sub set_city_type {
    my $citytypelist=$xml_data->{'citytype'}->{'city'};
    my $citytype = roll_from_array( &d(100), $citytypelist );

    $city->{'base_pop'}    = $citytype->{'base_pop'};
    $city->{'type'}        = $citytype->{'type'};
    $city->{'description'} = $citytype->{'content'};
    $city->{'add_other'}   = $citytype->{'add_other'};
}


###############################################################################
#
# set_city_size - Find the size of the city by selecting from the citysize 
# list, then populate the size, gp limit, population, and size modifier.
#
###############################################################################
sub set_city_size {
    set_seed( $seed);
    my $citysizelist=$xml_data->{'citysize'}->{'city'} ;
    my $citysize = roll_from_array( &d(100), $citysizelist );

    $city->{'size'}                 = $citysize->{'size'};
    $city->{'gplimit'}              = $citysize->{'gplimit'};
    $city->{'population'}->{'size'} = $citysize->{'minpop'} + &d( $citysize->{'maxpop'} - $citysize->{'minpop'} );
    $city->{'size_modifier'}        = $citysize->{'size_modifier'};
}

#######################################################################################################################
################                                                                                       ################
################                            These are more generic functions                           ################
################                                                                                       ################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################


###############################################################################
#
# set_seed - check the parameters for cityID and set the seed accordingly.
# This is what allows us to return to previously generated hosts.
#
###############################################################################
sub set_seed{
    my ($newseed)=@_;
    if (defined $newseed and  $newseed=~/(\d+)/){
        $newseed= $1;
    }else{
        $newseed = int rand(1000000);
    }
    srand $newseed;
    $seed=$newseed;
    return $newseed;
}


###############################################################################
#
# rand_from_array - select a random item from an array.
#
###############################################################################
sub rand_from_array {
    my ($array) = @_;
    srand $seed;
    my $index = int( rand( scalar @{ $array} ) );
    return $array->[$index];
}

###############################################################################
#
# roll_from_array - When passed a roll and a list of items, check the
# min and max properties of each and select the one that $roll best fits
# otherwise use the first item.
# 
###############################################################################
sub roll_from_array {
    my ( $roll, $items ) = @_;
    my $selected_item = $items->[0];
    for my $item (@$items) {
        if (defined $item->{'min'} and defined $item->{'max'} ){
            if ( $item->{'min'} <= $roll and $item->{'max'} >= $roll ) {
                $selected_item = $item;
                last;
            }
        }elsif ( defined $item->{'min'}   and ! defined $item->{'max'} ){
            if ( $item->{'min'} <= $roll ) {
                $selected_item = $item;
                last;
            }
        }elsif ( ! defined $item->{'min'} and   defined $item->{'max'} ){
            if ( $item->{'max'} >= $roll ) {
                $selected_item = $item;
                last;
            }
        }elsif ( ! defined $item->{'min'} and !  defined $item->{'max'} ){
                $selected_item = $item;
                last;
        }
    }
    return $selected_item;
}

###############################################################################
#
# d - this serves the function of rolling a dice- a d6, d10, etc.
#
###############################################################################
sub d {
    my ($die) = @_;
    # d as in 1d6
    if ($die =~/^\d+$/){
        return int( rand($die)+1 );
    }elsif ($die=~/^(\d+)d(\d+)$/){
        my $dicecount=$1;
        my $die=$2;
        my $total=0;
        while ($dicecount-- >0){
            $total+=&d($die);
        }
        return $total;
    }else{
        return 1;
    }
}

#####################################################
#
# Parse Object - a horribly named subroutine to parse
# out and randomly select the parts.
#
#####################################################
sub parse_object {
    my ($object)=@_;
    my $newobj= { 'content'=>'' };
    # We currently only care about 4 parts
    foreach my $part (qw/title pre root post trailer/){
        # Make sure that the part exists for this object.
        if(defined $object->{$part}){

            my $newpart;
            # If the object is an array, we're going to shuffle
            # the array and select one of the elements.
            if ( ref($object->{$part}) eq 'ARRAY'){
                # Shuffle the array and pop one element off
                my @parts=shuffle( @{$object->{$part}});
                $newpart=pop(@parts);

            # If the object is a Hash, we presume that there's only one choice
            } elsif ( ref($object->{$part}) eq 'HASH'  and $object->{$part}->{'content'}){
                # rename for easier handling
                $newpart=$object->{$part};
            }

            # make sure the element has content;
            # ignore it if it doesn't.
            if (defined $newpart->{'content'}){
                if (
                        # If no chance is defined, add it to the list.
                        (!defined $object->{$part.'_chance'}) or
                        # If chance is defined, compare it to
                        # the roll, and add it to the list.
                        (defined $object->{$part.'_chance'} and &d(100) <= $object->{$part.'_chance'}) ) {
                    
                    $newobj->{$part}=$newpart->{'content'};
                    if ($part eq 'title'){  
                        $newpart->{'content'}="$newpart->{'content'} " ;
                    }elsif ($part eq 'trailer'){  
                        $newpart->{'content'}=" $newpart->{'content'}" ;
                    }
                    $newobj->{'content'}.= $newpart->{'content'};
                }
            }
        }
    }
    # return the slimmed down version
    return $newobj;
}

1;
