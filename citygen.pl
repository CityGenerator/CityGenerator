#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use XML::Simple;

my $xml = new XML::Simple;
my $city_files="my_cities/";
# $xml_data will be treated as a global since we don't change it.

my $xml_data = $xml->XMLin(   "data.xml", ForceContent => 1, ForceArray  =>[]  );

# Let's attempt to un-cluster this bitch. First thing we need to do is establish
# a city skeleton of information, then fill it in as needed by each subsection of
# the sample text.

# This is our city object- it can and will be exported to xml eventually, so keep it clean.
my $city;


if (defined $ARGV[0] and -e $ARGV[0]){
    # load a city if the path to one is given.
    print "passed a city...\n";
    $city = $xml->XMLin(   $ARGV[0], ForceContent => 1, ForceArray  =>[]  );
}

#print Dumper($city);
#exit;

$city=&generate_city_skel($city)                             if (! defined $city);
$city->{'location'}=&generate_location($city)                if (! defined $city->{'location'});
$city->{'population'}=&calculate_population($city)           if (! defined $city->{'population'});
$city->{'time'}=&generate_random($xml_data->{'time'})        if (! defined $city->{'time'});
$city->{'weather'}=&generate_random($xml_data->{'weather'})  if (!defined $city->{'weather'} and !defined $city->{'location'}->{'weather'});
$city->{'events'}=&generate_random($xml_data->{'events'});
$city->{'taverns'}=&generate_taverns($city)                  if (! defined $city->{'taverns'});

$city->{'blackmarket'}=&generate_blackmarket($city);

#print Dumper($city->{'weather'});
#print Dumper($city->{'events'});

#print Dumper($xml_data);

#print Dumper($xml_data->{'blackmarket'});
#print Dumper($city);
#print "lets generate some treasure...\n";
#my $treasure_data = $xml->XMLin(   "treasure.xml", ForceContent => 1, ForceArray  =>[]  );

#print Dumper($treasure_data);
print "=========\n";
print Dumper(&generate_treasure('test'));
#print "results.. ".Dumper( &generate_treasure('3')  );
#print "test...".Dumper($treasure_data->{'level'}->{'1'})."...\n";

#print Dumper(&generate_random($structure," "));
#TODO: eventually this should be uncommented, but the 43 cities that I made tell me to leave
#it commented out a little longer,
&write_file($city);
#print Dumper($city);



exit;

######################################################################
######################################################################

sub generate_treasure{
    use vars qw ($xml_data $treasure_data);
    my ($level)=@_; # will either be an array or a hash
    my $treasure={};
    print "generating...\n";
    if (defined $treasure_data->{'level'}->{$level}){
        print "level is defined '$level'\n";
        $treasure=&generate_random($treasure_data->{'level'}->{$level});
        print Dumper($treasure);
        
    }
    for my $type (keys %{ $treasure }  ){
        if (defined $treasure->{$type}->{'dice'} and defined $treasure->{$type}->{'die'} ){
            my $total=0;
            for (my $i=0;$i<$treasure->{$type}->{'dice'};$i++){
                $total+=&d( $treasure->{$type}->{'die'} );
            }
            if (defined $treasure->{$type}->{'multiplier'}){
                $total=$total*$treasure->{$type}->{'multiplier'};
            }
            $treasure->{$type}={
                    'content'=>$treasure->{$type}->{'content'},
                    'value'  =>$total,
            };     
        }else{
            $treasure->{$type}={
                    'content'=>$treasure->{$type}->{'content'},
                    'value'  =>1,
            };     
        
        }
        if (!defined $treasure->{$type}->{'content'}){
           delete  $treasure->{$type};
        }
#        print Dumper($treasure_data->{'gems'});
#        print "== ".$treasure->{$type}->{'content'}." == ".$treasure_data->{$treasure->{$type}->{'content'}}."==\n";
        if (defined $treasure->{$type}->{'content'}  and defined $treasure_data->{$treasure->{$type}->{'content'}} 
                                                                        and  $treasure->{$type}->{'content'} eq 'gems'   ){ 
            my $goodies={};
#            print "##".Dumper($treasure->{$type})."\n";
            $treasure->{$type}->{'value'}=1 if (!defined $treasure->{$type}->{'value'});
#            print "##".$treasure->{$type}->{'value'}."\n";
            for (my $i=0;$i<$treasure->{$type}->{'value'};$i++){
#            print "a gem...\n";
                my $item= &generate_random( $treasure_data->{$treasure->{$type}->{'content'}}   );
                delete $item->{'min'};
                delete $item->{'max'};
#                print Dumper($item);
#                print "======================\n";
                my $total=0;
                for (my $i=0;$i<$item->{'dice'};$i++){
#                    print "loop";
                    $total+=&d( $item->{'die'} );
                }
                if (defined $item->{'multiplier'}){
                    $total=$total*int($item->{'multiplier'}-$item->{'multiplier'}*.05);
#                    print "pre ".$total."\n";
                    $total+=int rand($item->{'multiplier'}*.10);
#                    print "post ".$total."\n";
                }
                                                        
                $goodies->{$i}={};
                $goodies->{$i}->{'content'}=$item->{'type'}->{'content'};
                $goodies->{$i}->{'unit'}=$item->{'unit'};
                $goodies->{$i}->{'value'}=$total;
                
            }
            $treasure->{$type}=$goodies;
        
        }elsif (defined $treasure->{$type}->{'content'}  and defined $treasure_data->{$treasure->{$type}->{'content'}} 
                                                                        and  $treasure->{$type}->{'content'} eq 'mundane'   ){ 
            my $goodies={};
            print "=======".Dumper($treasure->{$type})."==========\n";
            for (my $i=0;$i<$treasure->{$type}->{'value'};$i++){
                my $item= &generate_random($treasure_data->{$treasure->{$type}->{'content'}});

                delete $item->{'min'};
                delete $item->{'max'};
                #print Dumper($item);
                if (defined $item->{'condition'}){
                    my $category=$item->{'condition'};
                    $item->{'category'}->{'condition_miltiplier'}=$item->{'condition'}->{'multiplier'};
                    $item->{'category'}->{'condition'}=$item->{'condition'}->{'content'};
                }
                $item=$item->{'category'};
                if (defined $item->{'type'}){
                    for my $key (keys %{ $item->{'type'}}){
                        $item->{$key}=$item->{'type'}->{$key};
                    }
                    delete $item->{'type'};
                
                }
                if (defined $item->{'masterwork_chance'} and $item->{'masterwork_chance'} >= &d(100)){
                    print $item->{'masterwork'}="true";
                    delete $item->{'masterwork_chance'};
                }
####                print Dumper($item);
####                print "======================\n";
###                my $total=0;
###                for (my $i=0;$i<$item->{'dice'};$i++){
####                    print "loop";
###                    $total+=&d( $item->{'die'} );
###                }
###                if (defined $item->{'multiplier'}){
###                    $total=$total*int($item->{'multiplier'}-$item->{'multiplier'}*.05);
####                    print "pre ".$total."\n";
###                    $total+=int rand($item->{'multiplier'}*.10);
####                    print "post ".$total."\n";
###                }
###
###                delete $item->{'dice'};
###                delete $item->{'die'};
###                if (defined $item->{'size'}){
###                $item->{'size'}=$item->{'size'}->{'content'};
###                }
###
                $goodies->{$i}=$item;
###                $goodies->{$i}->{'count'}=$total||1;
####                $goodies->{$i}->{'value'}=$item->{'value'};
                
            }
            print "=======".Dumper($goodies)."==========\n";
            $treasure->{$type}=$goodies;
             
        }
        
    }
    
    
    return $treasure;
}


sub generate_blackmarket{
    use vars qw ($xml_data);
    my ($city)=@_; # will either be an array or a hash
    my $blackmarket;
    $blackmarket=&generate_random($xml_data->{'blackmarket'});



    return $blackmarket;

}

sub prune_structure{
    use vars qw ($xml_data);
#    print "hello\n";
    my ($structure)=@_; # will either be an array or a hash
        if (ref($structure) eq "HASH" ){
            for my $key (keys %{$structure} ){
#           print "my key is $key "."\n";
                if ($structure->{$key} eq "" or    ( ref($structure->{$key}) eq "HASH"  and  scalar(keys %{$structure->{$key}}) == 0  ) ){
#                    print "deleting $key because it's not defined\n";
                    delete $structure->{$key};
                    
                }else{ 
                    $structure->{$key}=&prune_structure($structure->{$key});
                }
            }
        }elsif(ref($structure) eq "ARRAY" ){
            for (my $i=0 ; $i< @{$structure} ; $i++){
                if (!defined $structure->[$i]){
                    $structure=splice(@{$structure},$i,1);
                    $i--;
                }else{
                    $structure->[$i]=&prune_structure( $structure->[$i] );
                }
            }
        }

    return $structure;
}



sub generate_taverns{
    use vars qw ($xml_data);
    my ($city)=@_; # will either be an array or a hash
    my $taverns=&generate_random($xml_data->{'taverns'});
    $taverns->{'pop_count'}=      int ($city->{'size'}->{'modifier'}+6)   *( int rand($city->{'time'}->{'bar_mod'})  +    int($taverns->{'size'}->{'pop_mod'}));
    $taverns->{'pop_breakdown'}=[];
    my $totalpercent=0;
    my $actual_pop=0;
    my $race_count=scalar(@{$city->{'populationtype'}->{'percentage'}});
    for (my $i=0; $i<$race_count;$i++){
        my $percentage=$city->{'populationtype'}->{'percentage'}[$i];
        $taverns->{'pop_breakdown'}[$i]->{'percentage'}=$percentage->{'content'};
        $taverns->{'pop_breakdown'}[$i]->{'race'}=$percentage->{'race'}->{'content'};
        $taverns->{'pop_breakdown'}[$i]->{'count'}=abs(int(  ($taverns->{'pop_count'}-2)/$percentage->{'content'}) + int(rand(5)))  ;
       $actual_pop+= $taverns->{'pop_breakdown'}[$i]->{'count'} ;
    }
    $taverns->{'pop_count'}=$actual_pop;

    for (my $i=0; $i<scalar @{ $taverns->{'pop_breakdown'} };$i++){
        $taverns->{'pop_breakdown'}[$i]->{'percentage'}=int( $taverns->{'pop_breakdown'}[$i]->{'count'}/$actual_pop*1000)/10;
    }
    
    $taverns->{'pop_breakdown'}  = [ grep( { $_->{'count'} != 0}  @{ $taverns->{'pop_breakdown'}  }) ];
        
    return $taverns;
}







sub calculate_population{
    use vars qw ($xml_data);
    my ($city)=@_; # will either be an array or a hash
    my $output_item={};
    # determine rough random population
    my $rough_pop= int rand ($city->{'size'}->{'maxpop'} -$city->{'size'}->{'minpop'}) +$city->{'size'}->{'minpop'};
    my $real_pop=int($rough_pop*.01);
    # determine population per race
    for (my $i =0;$i <scalar(@{$city->{'populationtype'}->{'percentage'}  }) ; $i++ ){
        #race count= rough_pop*percentage/100
        $city->{'populationtype'}->{'percentage'}[$i]->{'count'}=int( $rough_pop*$city->{'populationtype'}->{'percentage'}[$i]->{'content'}/100);
        $real_pop+=$city->{'populationtype'}->{'percentage'}[$i]->{'count'};
    }
    for (my $i =0;$i <scalar(@{$city->{'populationtype'}->{'percentage'}  }) ; $i++ ){
        #race count= rough_pop*percentage/100
        $city->{'populationtype'}->{'percentage'}[$i]->{'content'}=int( $city->{'populationtype'}->{'percentage'}[$i]->{'count'}/$real_pop*10000)/100;
#        $real_pop+=$city->{'populationtype'}->{'percentage'}[$i]->{'count'};
    }


    return $real_pop;
    # add 1% of population+1 to total
    # return total

}


sub generate_random{
    # when passed a structure, look at it's children items
    # if children items are a hash, do one of the following
    #   hash containing type, choose one
    #   other recurse
    #
    use vars qw ($xml_data);
    my ($structure,$spacer)=@_; # will either be an array or a hash
    my $output_item={};
    if (!defined $spacer or $spacer eq""){$spacer=" "}
#    print "$spacer running genrand\n";
    
    if (!defined $structure->{'chance'} or  $structure->{'chance'} >= &d(100)){
        #limit is ignored if under 0; warning, HACK. 
        my $limit=-1;
        if (defined $structure->{'limit'}){
            $limit=int (rand($structure->{'limit'}))+1;
        }
        my @keys= keys %{ $structure } ;
        @keys = grep( { $_ ne "limit"}  @keys); 
        @keys = grep( { $_ ne "chance"}  @keys); 
        @keys = grep( { $_ ne "parent_chance"}  @keys); 
        @keys = grep( { $_ ne "category_name"}  @keys); 
        for my $key (&randomize_list( @keys  )  ){
#            print "$spacer checking $key  (".ref($structure->{$key}).")\n";
            if (ref($structure->{$key}) eq 'HASH'){
#                print "$spacer recursing...\n";
                if (!defined $structure->{$key}->{'parent_chance'}  or $structure->{$key}->{'parent_chance'} >= &d(100) ){
                    $output_item->{$key}=&generate_random($structure->{$key},$spacer."  ");
                }
#                print "$spacer return from recurse on $key\n";
            }
            elsif(ref($structure->{$key}) eq 'ARRAY'){
#                print "$spacer $key is an array.\n";
                # The only time it's ever an array, you have to choose only one.
                my $item_id=int rand(scalar(@{$structure->{$key}}));
#                print "$spacer we're using $item_id(".scalar(@{$structure->{$key}}).") in $key\n";
                # assign this type to our output structure
                if ($key eq "option"){
                    $output_item={};
                    $output_item=&generate_random($structure->{$key}[$item_id],$spacer."  ");
                }else{
                    $output_item->{$key}={};
                    $output_item->{$key}=&generate_random($structure->{$key}[$item_id],$spacer."  ");
                }
                
            }else{
#                print "$spacer $key(".$structure->{$key}.") is probably content.\n";
                $output_item->{$key}=$structure->{$key};
            }
         
            $limit--;
            if ($limit == 0){
                #if we've hit 0, stop the for loop, we have enough.
                last;
            }
        }
#        
    }else{
#        print "$spacer there was a chance, but it's gone.\n";
    }
    return $output_item;

}



sub randomize_list{
    my @orig_arr=@_;
    
    my @templist;
#    print "orig_arr".Dumper(@orig_arr)."\n";
    while(@orig_arr){
        my $arr_item=rand(@orig_arr);
#        print "--".Dumper($arr_item);
        push(@templist, splice(@orig_arr, $arr_item, 1));
    }
#    print "returning templist ".Dumper(@templist)."\n";
return @templist;

}


sub generate_location{
    use vars qw ($xml_data);
    my ($city)=@_;
    my $location; 
    my $location_id=int rand(scalar(@{ $xml_data->{'location'} }));
    $location->{'content'}= $xml_data->{'location'}[$location_id]->{'content'};
    $location->{'landmarks'}=[];
    
    if(defined $xml_data->{'location'}[$location_id]->{'weather'}  and $xml_data->{'location'}[$location_id]->{'weather'} ){
        $location->{'weather'}="none";
    }
    
    foreach my $landmarks (@{ $xml_data->{'location'}[$location_id]->{'landmarks'} }){
        if ( $landmarks->{'chance'} >= &d(100)  ){
            push @{$location->{'landmarks'}}, $landmarks->{'content'};
        }
    }
    
    
    return $location;
}




sub generate_city_skel{
    ##################################
    # We'll need to determine the basics about the City- things that are needed to generate the 
    # rest of the data
    use vars qw ($xml_data);
    my ($city)=@_;

    $city->{'size'}=&select_city_size($city, &d(100) );
    $city->{'populationtype'}=&determine_population_type($city->{'size'},&d(100));
    $city->{'type'}=&select_city_type(&d(100));
    
    $city=&determine_racial_breakdown($city);
    $city->{'name'}=&generate_city_name();

    return $city;
}

sub generate_city_name{
    #####################################
    # Generate a City Name
    # There is the prefix, the root, the suffix and the trailer
    #
    use vars qw ( $xml_data );
    my $cityname="";
    # Generate prefix, if we should
    if ($xml_data->{'prefix'}->{'chance'} > &d(100)){
        $cityname= $xml_data->{'prefix'}->{'word'}[  &d(scalar(@{  $xml_data->{'prefix'}->{'word'}  }))    ]->{'content'}." ";
    }

    # Generate root and suffix
    $cityname.= $xml_data->{'root'}->{'word'}[  &d(scalar(@{  $xml_data->{'root'}->{'word'}  }) )]->{'content'};
    $cityname.= $xml_data->{'suffix'}->{'word'}[ &d(scalar(@{  $xml_data->{'suffix'}->{'word'}  }) )]->{'content'};

    # Generate trailer, if we should
    if ($xml_data->{'trailer'}->{'chance'} > &d(100)){
        $cityname.= " ".$xml_data->{'trailer'}->{'word'}[    &d(scalar(@{  $xml_data->{'trailer'}->{'word'}  }) )]->{'content'};
    }

    #return our new cityname
    return $cityname;
}


##################################

sub determine_racial_breakdown{
    use vars qw ($xml_data);
    my ($city)=@_;
    
    my $num_of_races=scalar(@{$city->{'populationtype'}->{'percentage'}});
    # Rules
    # look at city type for base races and monster/basic mod
    print "city is ".$city->{'type'}->{'content'}."\n" if ($xml_data->{'debug'}); 
    my @races= &get_races($city->{'type'}->{'base_pop'});
    for (my $i=0;$i<$num_of_races;$i++){
                
        my $target_race=$races[int rand(scalar(@races))];
        $city->{'populationtype'}->{'percentage'}[$i]->{'race'}=$target_race;
       print "placed ".$target_race->{'content'}."\n" if ($xml_data->{'debug'}); 
       @races = grep( {$target_race ne $_}  @races); 
    }
    
    if (defined $city->{'type'}->{'add_other'}){
        my @others= &get_races($city->{'type'}->{'base_pop'},"!");
        my $replacee_id=int rand(scalar(@{ $city->{'populationtype'}->{'percentage'} }));
        my $replacer_id=int rand(scalar(@others));
        print "replacing ".$city->{'populationtype'}->{'percentage'}[$replacee_id]->{'race'}->{'content'}  if ($xml_data->{'debug'});
        print " with ".$others[$replacer_id]->{'content'}."\n"    if ($xml_data->{'debug'});
        $city->{'populationtype'}->{'percentage'}[$replacee_id]->{'race'}=$others[$replacer_id];
    }

 
    return $city;
}



sub get_races{
    use vars qw ($xml_data);
    my ($race_type,$negate)=@_;
    my @races=();
    my @unchosen=();
    for my $race (@{ $xml_data->{"races"}->{'race'} }){
        if ( !defined $race_type or $race->{'type'} eq $race_type or $race_type eq ""){
            push @races,$race;
        }else{
            push @unchosen,$race;
        }
    }
    if (defined $negate and $negate eq "!"){
        return @unchosen;
    }else{
        return @races;
    }
    
}


sub select_city_type{
    use vars qw ($xml_data);
    my ($type_roll)=@_;
    for my $type ( @{  $xml_data->{'citytype'} }){
        if ($type->{'min'} <= $type_roll and $type->{'max'} >= $type_roll){
        return $type;
        }
    }
    die "There was a problem in select_city_type with a roll of$type_roll!";
}


sub determine_population_type{
    use vars qw ($xml_data);
    my ($citysize,$pop_roll)=@_;
    
    my @allowed_poptypes;
    for my $poptype ( @{ $xml_data->{'poptypes'}->{'pop'} } ){
        if ($poptype->{'minpop'} <= $citysize->{'minpop'}){
            push @allowed_poptypes,$poptype;
        }
    }
    return $allowed_poptypes[int rand(scalar(@allowed_poptypes))];

}

####################################


sub population_estimate{
    ###################################
    # Determine the population 
    my ($citysize)=@_;

    return int( rand($citysize->{'maxpop'} - $citysize->{'minpop'})  )+$citysize->{'minpop'};
}


sub select_city_size{
    ###################################
    # determine city size and type, including modifiers and population limits
    use vars qw ( $xml_data );
    my ($city, $size_roll)= @_;

    for my $citysize (@{ $xml_data->{'cities'}->{'city'} }){

        if (    $citysize->{'min'} <=  $size_roll   and    $citysize->{'max'} >= $size_roll  ){
            return $citysize;
        }
    }
    die "citysize wasn't found- math problem in generate_city_size!";

}



sub d{
    ######################
    # There are a lot of instances in DnD where you're asked to roll dice
    # this is a method of rolling a single die- good for getting 1d6 or 1d100
    my ($die)=@_;
    return int(rand($die))+1;
}


sub write_file{
    use vars qw ( $xml_data $xml $city_files);
    my ($city)=@_; #FIXME: this currently only works when in the citygen dir, otherwise it gets messy. use findbin!
    my $city_files="my_cities";
    if (! -e $city_files){
        mkdir $city_files;
    }
    my $cityname=$city->{'name'};
    $cityname=~s/ /_/;
    $city=&prune_structure($city);    
    my $xmltext = $xml->XMLout( $city, RootName=>"city_base");
    if (-e "$city_files/$cityname"){
        print "wtf, somehow $cityname is in use so I saved it as ";
        $cityname=$cityname.&d(1000);
        print "$cityname.  You might want to rename it or something...\n";
    }
    open OUTPUTFILE, ">$city_files/$cityname.xml";
    print OUTPUTFILE "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n\n";
    print OUTPUTFILE "\n<!-- WARNING! this file is auto-generated. any non-tag additions (such as comments) will be
     lost if you place them here. DO NOT COMMENT OUT LINES!!! -->\n\n";
    print OUTPUTFILE $xmltext;
    print OUTPUTFILE "<!-- last saved ".time."-->\n";
    close OUTPUTFILE;

    print "$city_files/$cityname.xml was saved successfully\n";
    print $xmltext."\n"  if ($xml_data->{'debug'});
}

