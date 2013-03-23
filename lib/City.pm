#!/usr/bin/perl -wT
###############################################################################
#
package City;

###############################################################################

=head2 generate_citizens()

given all of our specialists, are any noteworhy?

=cut

###############################################################################
sub generate_citizens {

    my $limit = $city->{'specialisttotal'};
    # no less than 0, no more than specialisttotal.
    my $citizencount = min( $city->{'specialisttotal'}, int( &d( 6 + $city->{'size_modifier'} ) - 1 ) );

    $city->{'citizens'} = [];
    my $businesslist = $city->{'business'};
    while ( $citizencount-- > 0 ) {
        $GenericGenerator::seed++;
        my $npc=NPCGenerator::create_npc({seed=>$GenericGenerator::seed    });

        NPCGenerator::set_profession($npc, [shuffle keys %$businesslist] );

        delete $businesslist->{ $npc->{'business'}  };

        if ( scalar keys %$businesslist == 0 ) {
            $businesslist = $city->{'business'};
        }
        push @{ $city->{'citizens'} }, $npc;
    } ## end while ( $citizencount-- >...)
    set_seed($originalseed);
} ## end sub generate_citizens

###############################################################################

=head2 generate_watchtowers()

 come up with a list of towers

=cut

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

=head2 generate_kingdom_troops()

generate troops dedicated to protecting the kingdom.

=cut

###############################################################################

sub generate_kingdom_troops {
    $city->{'militarystats'}->{'kingdompercent'}=max(0, &d(8)*5 + $city->{'size_modifier'});
    
    $city->{'militarystats'}->{'kingdom'}       = int($city->{'militarystats'}->{'active'} * $city->{'militarystats'}->{'kingdompercent'}/100);
    $city->{'militarystats'}->{'kingdompercent'}= int($city->{'militarystats'}->{'kingdom'}/ $city->{'militarystats'}->{'active'} * 1000)/10;
    
}

###############################################################################

=head2 generate_military_stats()

generate statistics on active, para, reserve, etc of the military

=cut

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

=head2 generate_events()

determine what is going on in the city currently.

=cut

###############################################################################
sub generate_events {
    my $event_chance=$xml_data->{'events'}->{'chance'};
    my $limit=max(2, $city->{'size_modifier'}/2);
    $city->{'eventslimit'}=$limit;
    $city->{'events'}=[];
    my @events;
    for my $event (shuffle @{ $xml_data->{'events'}->{'event'} } ){
        $GenericGenerator::seed++;
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

=head2 generate_visible_population()

determine what percentage of the population is out and about.

=cut

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

=head2 generate_education_description()

generate the economic description

=cut

###############################################################################
sub generate_education_description {
    my $educationtype     = roll_from_array( $city->{'education'}, $xml_data->{'educationalignment'}->{'option'} );
    my $adjective     = rand_from_array( $educationtype->{'adjective'} )->{'content'};
    $city->{'educationdescription'}=$adjective;
}

###############################################################################

=head2 generate_magic_description()

generate the economic description

=cut

###############################################################################
sub generate_magic_description {
    my $magictype     = roll_from_array( $city->{'magic'}, $xml_data->{'magicalignment'}->{'option'} );
    my $adjective     = rand_from_array( $magictype->{'adjective'} )->{'content'};
    $city->{'magicdescription'}=$adjective;
}

###############################################################################

=head2 generate_economic_description()

generate the economic description

=cut

###############################################################################
sub generate_economic_description {
    my $econtype     = roll_from_array( $city->{'economy'}, $xml_data->{'economyalignment'}->{'option'} );
    my $adjective     = rand_from_array( $econtype->{'adjective'} )->{'content'};
    $city->{'economydescription'}=$adjective;
}

###############################################################################

=head2 generate_travelers()

generate a few travelers

=cut

###############################################################################
sub generate_travelers{
    my $travelercount= int( ( 6 +  $city->{'size_modifier'} )/2);
    $city->{'travelers'}=[];
    while ($travelercount-- ){
        $GenericGenerator::seed++;
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

=head2 generate_taverns()

generate a few taverns;

=cut

###############################################################################

sub generate_taverns{
    my $taverncount=0;
    if (defined $city->{'business'}->{'tavern/inn'}){
        $taverncount+=$city->{'business'}->{'tavern/inn'}->{'count'};
    }
    $taverncount=min(5 ,  $taverncount);
    $city->{'taverns'}=[];
    while ($taverncount-- > 0){
        $GenericGenerator::seed++;
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

=head2 generate_bartender()

generate a bartender

=cut

###############################################################################
sub generate_bartender{


    my @races=get_races(   $city->{'base_pop'}    );
    shuffle @races;

    my $bartender=NPCGenerator::create_npc({ 'race'   => pop(@races)->{'content'},
                                'level' => min( 20 ,max(1, &d("3d4")+ &d( $city->{'size_modifier'} )) )
                            });
    return $bartender;
}


###############################################################################

=head2 generate_markets()

select some markets according to their chance of 
 appearance modified by city size.

=cut

###############################################################################
sub generate_markets {

    $city->{'markets'}=[];
    # minimum of 2 markets, max of size modifier(9)
    my $marketcount= max(2, &d( int(6 + $city->{'size_modifier'})/2     ));


    # loop through the marketcount to randomly select markets
    # this allows us to get "duplicates"
    my $tries=scalar( @{ $xml_data->{'markets'}->{'option'} })*2;
    while ( $marketcount > 0 and $tries-- >0){
        $GenericGenerator::seed++;
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

=head2 generate_climate()

Determine the climate of the city

=cut

###############################################################################
sub generate_climate {
    $city->{'climate'}=rand_from_array($xml_data->{'climate'}->{'option'});
}


###############################################################################

=head2 generate_topography()

Determine information about the neighbors. 

=cut

###############################################################################
sub generate_topography {
    $city->{'topography'}=rand_from_array($xml_data->{'topography'}->{'region'})->{'content'};
}

###############################################################################

=head2 generate_neighborRealms()

Determine information about the neighbor Realms. 

=cut

###############################################################################

sub generate_neighborRealms {

    $city->{'regions'}=[];
    my $continentseed=$originalseed-$originalseed%100;
    for (my $i = 0 ; $i < 10; $i++){
        my $regionseed=$continentseed+$i*10;
        set_seed($regionseed);
        my $region={}; 
        $region->{'id'}=$regionseed;
        $region->{'name'}= parse_object($xml_data->{'region'})->{'content'};
        #$city->{'relation'} =" $neighborid + $originalseed  = $GenericGenerator::seed  " .rand_from_array(  $xml_data->{'neighbor'}->{'relation'}  )->{'content'};
        push @{$city->{'regions'}}, $region;
    }
    set_seed($originalseed);
}


###############################################################################

=head2 generate_neighbors()

Determine information about the neighbors. 

=cut

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
        $city->{'relation'} =" $neighborid + ".$originalseed."  = $GenericGenerator::seed  " .rand_from_array(  $xml_data->{'neighbor'}->{'relation'}  )->{'content'};

        push @{$origcity->{'neighbors'}}, $city;
    }
    set_seed($originalseed);
    $city=$origcity
}


###############################################################################

=head2 generate_streets()

Determine information about the streets. 

=cut

###############################################################################
sub generate_streets {
    $city->{'streets'}=parse_object($xml_data->{'streets'});

    $city->{'streets'}->{'mainroads'}=max(0,   int(($city->{'travel'}+$city->{'economy'})/3)  );
    $city->{'streets'}->{'roads'}=max(1,   int(($city->{'travel'}+$city->{'economy'})/3) + $city->{'streets'}->{'mainroads'}  );


}

###############################################################################

=head2 adjust_chance_for_port()

If the city location has the port value set, git the port district an 80% chance.

=cut

###############################################################################
sub adjust_chance_for_port{
    if ( $city->{'location'}->{'port'}  ) {
        $xml_data->{'districts'}->{'district'}->{'port'}->{'chance'}=80;
    }
}

###############################################################################

=head2 specialists_influence_districts()

Use the city buildings and businesses to influence the corresponding districts chance. 

=cut

###############################################################################
sub specialists_influence_districts{

    foreach my $business (@{$city->{'buildings'}}){
        my $district=$city->{'business'}->{$business->{'content'}}->{'district'};
        $xml_data->{'districts'}->{'district'}->{$district}->{'chance'}+= $city->{'business'}->{$business->{'content'}}->{'specialists'} ;
    }

}

###############################################################################

=head2 generate_districts()

using population size and professionals, determine the most likely districts.

=cut

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

=head2 generate_businesses()

using population size and professionals, determine the most likely districts.

=cut

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
    for my $businessname ( sort keys  %{ $business_data->{'building'} }   ){
        my $business=$business_data->{'building'}->{$businessname };
        $business->{'content'}=$businessname ; # This is a kludge workaround.
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

=head2 generate_support_area()

using population size, determine the size of the area needed to support 
the city. results is in square miles.

=cut

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

=head2 generate_area()

using population size and density, determine the size of the city. 
Results is in hectares.

=cut

###############################################################################
sub generate_area {
    # Population * (feet per person - sizemodifier*10 ) =total feet per population adjusted for city size
    $city->{'area'}=   int( $city->{'population'}->{'size'}*( $city->{'popdensity'}->{'feetpercapita'}-$city->{'size_modifier'}*10   ) /107639*100 )/100; #hectares;

}

###############################################################################

=head2 generate_housing()

generate the types of housing and how much there is.

=cut

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

=head2 generate_location()

select the location we wish to use and any landmarks.

=cut

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

###############################################################################

=head2 generate_crime()

Generate crime statistics and details

=cut

###############################################################################

sub generate_crime{
    #higher means more crime
    # random -education + authority averaged with reversed morality.
    # low morality= high reversed morality, which raises the average
    my $crime_roll= int((&d(100) + $city->{'education'} - $city->{'authority'} + ( 100 - $city->{'moral'}) )/2);

    $city->{'crime'}= roll_from_array($crime_roll, $xml_data->{'crime'}->{'option'});
    $city->{'crime'}->{'roll'}=$crime_roll;

}

###############################################################################

=head2 generate_imprisonment_rate()

city size, authority, order and education determine what percentage 
of the city is in jail. 0.05% to  01.815%

=cut

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

=head2 generate_elderly()

set the percentage of the population that are elderly, modified by the age of the city

=cut

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

=head2 generate_children()

set the percentage of the population that are children, modified by the age of the city

=cut

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

=head2 generate_secondary_power()

select a plot, a power and a subplot.

=cut

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
    $city->{'secondarypower'}->{'subplot_chance'}=$power->{'subplot_chance'};
    if ( &d(100) <= $power->{'subplot_chance'} ){
        $city->{'secondarypower'}->{'subplot'} = rand_from_array(  $power->{'subplot'}  )->{'content'};
    }
}


###############################################################################

=head2 set_govt_type()

fairly simple; select a type of govt from the list.

=cut

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

=head2 generate_city_ethics()

Intended for morals and order (classic alignment).

=cut

###############################################################################
sub generate_city_ethics {
    foreach my $mod ( qw/ moral order/ ) {
        $GenericGenerator::seed++;
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
    $GenericGenerator::seed=set_seed($originalseed);
}
###############################################################################

=head2 generate_city_beliefs()

This includes other scales, such as determining if the city is a trade hub, etc. 

=cut

###############################################################################
sub generate_city_beliefs {

    # set the baseline random modifier
    foreach my $mod (qw/ magic authority economy education travel tolerance military / ){
        $GenericGenerator::seed++;
        $city->{$mod} =&d(5)-3;
        # adjust all modifiers for each race
        for my $race ( @{ $city->{'races'} } ) {
            $city->{$mod} += $race->{$mod};
        }

        # Use min/max to ensure that we fall in the proper ranges when all is said and done        
        $city->{$mod} = max(-5, min(5, $city->{$mod} ) );
        my $description=roll_from_array( $city->{$mod} , $xml_data->{$mod.'alignment'}->{'option'});
        $city->{$mod."description"}=rand_from_array( $description->{'adjective'})->{'content'};
    }
    $GenericGenerator::seed=set_seed($originalseed);

}

###############################################################################

=head2 generate_pop_counts()

For each race percentage. After getting  population counts, recalulate total 
population, then final percentages. Note that actual races are not yet associated.

=cut

###############################################################################
sub generate_pop_counts {
    my $population = $city->{'population'}->{'size'};
    my $newpop     = 0;
    my @races;
    my @newraces;

    # Loop through each race percentage, and get a rough count based
    # on population total
    for my $race ( sort {$a->{'percent'} <=> $b->{'percent'}  }   @{ $city->{'races'} } ) {
        $race->{'count'} = ceil( $population * $race->{'percent'} / 100 );
        $newpop += $race->{'count'};
        push @races, $race;
    }

    # Add up all of the rough counts to create a final population total
    $city->{'population'}->{'size'} = $newpop;
    $city->{'races'}      = \@races;

    # Loop through the races a second time, recalulating percentages.
    for my $race ( sort {$a->{'percent'} <=> $b->{'percent'}  }   @{ $city->{'races'} } ) {
        $race->{'percent'} = int( $race->{'count'} / $newpop * 1000 ) / 10;
        push @newraces, $race;
    }
    $city->{'races'} = \@newraces;
}


###############################################################################

=head2 assign_races()

Assigning a race consists of several different phases

=over

=item * looking at the base population type to gather available base races

=item * looping through the race percentages and assigning an available race

=item * adding an "off race" if applicable.

=item * adding 1% other

=back

=cut


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
        $GenericGenerator::seed++;
        my $roll= &d(10)-5 + $race->{'tolerance'} ;
        my $tolerancetype = roll_from_array( $roll , $xml_data->{'tolerancealignment'}->{'option'} );
        $race->{'tolerancedescription'}= rand_from_array( $tolerancetype->{'adjective'})->{'content'};
    }
    #replace race percentages with full race breakdowns.
    $city->{'races'} = \@races;
    set_seed($originalseed);
}


###############################################################################

=head2 add_race_features()

copy the features over for a given races. Effectively merges percent onto the race.

=cut

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

=head2 get_races()

get the races that match the given population type.
 If the type is mixed, add the race as long as it's not an other race.

=cut

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

=head2 get_other_race()

get the races that doesn't match the given population type.
 make sure to exclude other.

=cut

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


1;
