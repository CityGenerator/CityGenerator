#!/usr/bin/perl -wT
###############################################################################
#
package GenericGenerator;

use strict;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( set_seed rand_from_array roll_from_array d parse_object);


use Data::Dumper;
use List::Util 'shuffle', 'min', 'max';
use POSIX;


our $seed;


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
