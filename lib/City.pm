#!/usr/bin/perl -wT
###############################################################################
#
package City;



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
            }

            # push it to the queue
            push @{$city->{'markets'}}, $newmarket;

       } 

    }
    set_seed($originalseed);
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




1;
