#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use XML::Simple;

my $xml = new XML::Simple;



print "lets generate some treasure...\n";
my $treasure_data = $xml->XMLin(   "treasure.xml", ForceContent => 1, ForceArray  =>['option','type','category','size','level','condition']  );

#print Dumper($treasure_data);
#my $monsters=[1,1,1,1,1,1,1,1,1,1,1,1,1,1];
my $monsters=["test"];
my $treasure=[];
for (my $i=0; $i<scalar(@{ $monsters });$i++){
    $treasure->[$i]= &generate_treasure($monsters->[$i]);
}

#print "===============#\n============#\n".Dumper($treasure);
#print "===============#\n============#\n";
$treasure=&merge_treasure($treasure);
#print "===============#\n============#\n".Dumper($treasure);
#print "===============#\n============#\n";

#&pretty_print($treasure);
exit;

######################################################################
######################################################################

sub pretty_print{#TODO: don't forget to finish this
    my ($treasure)=@_;
    print "\n\n-------------------------------------------------\n";
    print "\nYou find the following:\n";
    print "\tcoinage: \n";
    for my $coinage ('cp','sp','gp','pp'){
        if ($treasure->{'coin'}->{$coinage} != 0 ){
            print "\t\t".$treasure->{'coin'}->{$coinage}." $coinage\n";
        }
    }
    print "\tItems: \n";
    for my $id (keys %{ $treasure->{'items'}  }){
        my $item=$treasure->{'items'}->{$id};
        print "\t\t item:      ".$item->{'content'}."\n"                    if (defined $item->{'content'});
        print "\t\t size:      ".$item->{'size'}     ."\n"                  if (defined $item->{'size'});
        print "\t\t condition: ".$item->{'condition'}."\n"                  if (defined $item->{'condition'});
        print "\t\t value:     ".$item->{'value'}.$item->{'unit'}    ."\n"  if (defined $item->{'value'});
        print "\t\t This item is of masterwork quality.\n"                  if (defined $item->{'masterwork'});
        print "\n"; 
        
    }
    print "\tGoods: \n";
    for my $id (keys %{ $treasure->{'goods'}  }){
        my $item=$treasure->{'goods'}->{$id};
        print "\t\t item:      ".$item->{'content'}."\n";
        print "\t\t size:      ".$item->{'size'}     ."\n" if (defined $item->{'size'});
        print "\t\t condition: ".$item->{'condition'}."\n" if (defined $item->{'condition'});
        print "\t\t value:     ".$item->{'value'}.$item->{'unit'}    ."\n" if (defined $item->{'value'});
        print "\n"; 
        
    }






    print     "\n";
#    print Dumper($treasure);
    exit;

}



sub merge_treasure{
    my ($treasure)=@_;
    my $hoarde={ 'coin'=>{'cp'=>0,'sp'=>0,'gp'=>0,'pp'=>0}, 'goods'=>{}, };
    my $goodcount=0;
    my $itemcount=0;
    for my $pot (@{$treasure}){
#        print Dumper($pot);
        if ($pot->{'coin'}){
            if (defined $pot->{'coin'}->{'content'} and defined $hoarde->{'coin'}->{$pot->{'coin'}->{'content'}} and $pot->{'coin'}->{'value'}=~/\d+/){
                $hoarde->{'coin'}->{$pot->{'coin'}->{'content'}}=$hoarde->{'coin'}->{$pot->{'coin'}->{'content'}}+$pot->{'coin'}->{'value'};
            }
        }
        if ($pot->{'goods'}){
            for my $goodname (keys %{  $pot->{'goods'}  }){
 #               print $goodname;
                my $good=$pot->{'goods'}->{$goodname};
                if (defined $good->{'condition'}){
                    $good->{'value'}=$good->{'condition'}->{'multiplier'} * $good->{'value'};
                    $good->{'condition'}=$good->{'condition'}->{'content'};
                }
                
                $hoarde->{'goods'}->{$goodcount}=$good;
                $goodcount++;
            }
        }
        if ($pot->{'items'}){
            for my $itemname (keys %{  $pot->{'items'}  }){
  #              print $itemname;
                my $tmpitem=$pot->{'items'}->{$itemname};
                my $category_name=
                            $tmpitem->{'category'}->{'category_name'}." (".
                            $tmpitem->{'category_name'}.")";
                delete $tmpitem->{'category'}->{'category_name'};
                if (defined $tmpitem->{'category'}->{'type'}->{'masterwork'}){
                    $tmpitem->{'category'}->{'type'}->{'value'}=$tmpitem->{'category'}->{'type'}->{'value'}+$tmpitem->{'category'}->{'masterwork_mod'};
                }
                delete $tmpitem->{'category'}->{'masterwork_mod'};
                
                for my $subkey (keys  %{   $tmpitem->{'category'}->{'type'}   }) {
                    $tmpitem->{$subkey}=$tmpitem->{'category'}->{'type'}->{$subkey}; 
                    delete $tmpitem->{'category'}->{'type'}->{$subkey};
                }
                delete $tmpitem->{'category'};
                $tmpitem->{'category_name'}=$category_name; 
                if (defined $tmpitem->{'condition'}){
                    $tmpitem->{'value'}=$tmpitem->{'condition'}->{'multiplier'} * $tmpitem->{'value'};
                    $tmpitem->{'condition'}=$tmpitem->{'condition'}->{'content'};
                
                }
                
                if (defined $tmpitem->{'size'}){
                    $tmpitem->{'size'}=$tmpitem->{'size'}->{'content'};
                }
                print Dumper($tmpitem);
                $hoarde->{'items'}->{$itemcount}=$tmpitem;
                
                $itemcount++;
            }
        }
    
    }
return $hoarde;

}


sub generate_treasure{
    use vars qw ($xml_data $treasure_data);
    my ($level)=@_; # will either be an array or a hash
    my $treasure={};
#    print "generating...\n";
    if (defined $treasure_data->{'level'}->{$level}){
#        print "level is defined '$level'\n";
        $treasure=&generate_random($treasure_data->{'level'}->{$level});
#        print Dumper($treasure);
    }
    for my $type (keys %{ $treasure }  ){
 #       print "foo on ".Dumper($treasure->{$type})."\n";
        
        $treasure->{$type}->{'content'}=$treasure->{$type}->{'option'}->{'content'};
        $treasure->{$type}->{'value'}=$treasure->{$type}->{'option'}->{'value'};
        delete $treasure->{$type}->{'option'};
        if (defined $treasure_data->{$treasure->{$type}->{'content'}}){
            if ($treasure->{$type}->{'content'} eq "minor"){
                print "woot\n";
            }
#            print "FOUND ".$treasure->{$type}->{'content'}."!\n";
            my $items={};
            $treasure->{$type}->{'value'}=1 if (!defined $treasure->{$type}->{'value'});
            
            for (my $i=0;$i<$treasure->{$type}->{'value'};$i++){
#               print "beep" if ($treasure->{$type}->{'content'} eq "mundane");
#               print "looking for $type\n";
                $items->{$i} = &generate_random( $treasure_data->{$treasure->{$type}->{'content'}}->{'option'} ,"##"  );
#                print "$items $i\n";
                if (defined $treasure_data->{$treasure->{$type}->{'content'}}->{'condition'}){
                    $items->{$i}->{'condition'} = &generate_random( $treasure_data->{$treasure->{$type}->{'content'}}->{'condition'} ,"##"  );
                }
  #              print "--".Dumper($items->{$i} );

            }
            $treasure->{$type}=$items;
        }

    }
    
    return $treasure;
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
#    print $spacer.Dumper($structure)."\n";
#    if ($spacer=~/##/){
#        print "found something".Dumper($structure)."\n";
#    }
    if (ref($structure) eq 'HASH'){
        # Loop through each hashitem and do something
        for my $key (keys  %{ $structure } ){
#            print $spacer.$key."\n";
            if ($key eq "multiple"){
                $structure->{'count'}=1 if (!defined $structure->{'count'});
                if (defined $structure->{'limit'}){
                    $structure->{'count'}= int rand($structure->{'limit'})+1 ;
                    delete $structure->{'limit'};
                }
                for (my $i=0;$i<$structure->{'count'};$i++){
#                    print "##### run $i through the loop, there are ".@{ $structure->{$key} }." items in the loop\n";
                    if (@{ $structure->{$key} } eq 0){print "all out. exiting loop\n" ;last;}
                    my $selected=int rand(scalar(  @{ $structure->{$key} }  ));
#                    print $selected;
                    # output_item->{'multiple'}->[a,b,c];
                    $output_item->{$key}->{$i}=&generate_random( $structure->{$key}[$selected],$spacer."  ");
                    $structure->{$key} = [ grep( { $_ != $structure->{$key}[$selected]}  @{ $structure->{$key}  }) ];
                }
                delete $output_item->{'count'};
            }else{
                if (defined $structure->{'option'} and defined $structure->{'option'}[0]->{'min'} ){
                    my $roll=&d(100);
#                    print "I rolled a $roll\n";
                    for my $item (@{  $structure->{'option'}  } ){
                        if ($roll >= $item->{'min'} and $roll <= $item->{'max'}){
#                            print "we're taking a ".Dumper($item)." for ".Dumper($structure)."\n";
                            $output_item->{$key}=&generate_random($item,$spacer."  ");
                        }
                    }
                
#                    print "ooh look a $key ".$structure->{$key}."\n";
                }else{
                    $output_item->{$key}=&generate_random($structure->{$key},$spacer."  ");
                }
            }
##            print ref($output_item->{$key})."--".$output_item->{$key};
            if  (
                   (ref($output_item->{$key}) eq 'HASH'  and  scalar(keys %{$output_item->{$key}}) ==0) or
                   (ref($output_item->{$key}) eq 'ARRAY' and  scalar(     @{$output_item->{$key}}) ==0) or
                   ($output_item->{$key} eq '')
                   
                   ){
#                print "===============wtf??\n";
                delete $output_item->{$key};
            }
        
        }
        
        if (  defined $output_item->{'type'} and scalar(keys %{ $output_item->{'type'} }) == 1  and  defined $output_item->{'type'}->{'content'}){
            
#            print scalar(keys %{$output_item->{'type'}})."(".Dumper($output_item->{'type'}).") exists!!\n";
            $output_item->{'content'}=$output_item->{'type'}->{'content'};
            delete $output_item->{'type'};
        }
        if (defined $output_item->{'masterwork_chance'}){
            if ($output_item->{'masterwork_chance'} >= &d(100)  ){
               $output_item->{'masterwork'}='true';
            }
            delete $output_item->{'masterwork_chance'};
        }
        if (defined $output_item->{'dice'}  and defined $output_item->{'die'}){
#            print $spacer."we found ".$output_item->{'dice'}." dice\n";
            $output_item->{'value'}=&calc_dice($output_item->{'dice'},$output_item->{'die'});
            if (defined $output_item->{'multiplier'}){
                #    value = 95% of value + rand( 10% of value)
                $output_item->{'value'}=$output_item->{'value'}*$output_item->{'multiplier'}*.95 
                                           + int rand($output_item->{'value'}*$output_item->{'multiplier'}*.1);
                delete $output_item->{'multiplier'};
            }
            delete $output_item->{'dice'};
            delete $output_item->{'die'}
        }


        
    }elsif (ref($structure) eq 'ARRAY'){
        # Loop through each element and do something
        $output_item=&generate_random($structure->[int rand(scalar(@{$structure})) ],$spacer."  "  );

    }elsif (ref($structure) eq 'SCALAR'){
        $output_item=\$structure;
    }elsif (ref($structure) eq ''){
        $output_item=$structure;
    }else{
#        print ref($structure)."---\n";
        die "wtf is left???";
    }
    
    if (ref($output_item) eq 'HASH' and  defined $output_item->{'min'}){
        delete $output_item->{'min'};
        delete $output_item->{'max'};
    }
#    print Dumper($output_item);
    return $output_item;

}


sub prune_structure{
    use vars qw ($xml_data);
#    print "hello\n";
    my ($structure)=@_; # will either be an array or a hash
        if (ref($structure) eq "HASH" ){
            for my $key (keys %{$structure} ){
#           print "my key is $key "."\n";
                if (!defined $structure->{$key} or $structure->{$key} eq "" or    ( ref($structure->{$key}) eq "HASH"  and  scalar(keys %{$structure->{$key}}) == 0  ) ){
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
sub calc_dice{
    my ($dice,$die)=@_;
    my $total=0;
    for (my $i=0;$i<$dice;$i++){
        $total+=&d($die);
    }
    return $total;
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



sub d{
    ######################
    # There are a lot of instances in DnD where you're asked to roll dice
    # this is a method of rolling a single die- good for getting 1d6 or 1d100
    my ($die)=@_;
    return int(rand($die))+1;
}


