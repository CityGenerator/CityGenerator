#!/usr/bin/perl -wT
###############################################################################
#
package City;

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

sub generate_kingdom_troops {
    $city->{'militarystats'}->{'kingdompercent'}=max(0, &d(8)*5 + $city->{'size_modifier'});
    
    $city->{'militarystats'}->{'kingdom'}       = int($city->{'militarystats'}->{'active'} * $city->{'militarystats'}->{'kingdompercent'}/100);
    $city->{'militarystats'}->{'kingdompercent'}= int($city->{'militarystats'}->{'kingdom'}/ $city->{'militarystats'}->{'active'} * 1000)/10;
    
}


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


sub generate_topography {
    $city->{'topography'}=rand_from_array($xml_data->{'topography'}->{'region'})->{'content'};
}


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
