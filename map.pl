#!/usr/bin/perl -w
use strict;
use CGI;
use Data::Dumper;
use GD;
use List::Util 'shuffle', 'min', 'max' ;
use POSIX;
use XML::Simple;

our $q = CGI->new;
our $seed=set_seed();
srand $seed;

our $height=500;
our $width=500;

our $img = GD::Image->new($width,$height);
our $palette = {
    # create a new image
    # allocate some colors
    'grass' => $img->colorAllocate(17,83,7),
    'ocean' => $img->colorAllocate(14,43,104),
    'road'  => $img->colorAllocate(66,30,3),
    'wall'  => $img->colorAllocate(97,97,97),
};


&draw_ocean();
&select_land_pattern();

if (defined $q->param('debug')) {
    exit;
}
&finish();
exit;

#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
sub select_land_pattern{
    my $poly = new GD::Polygon;
    my @sides=('north', 'south', 'east', 'west' );
    my $sidelist=join '|',@sides;
    my $side='west';
    if (defined $q->param('side') and $q->param('side') =~/north|south|east|west/){
        $side=$q->param('side');
    }


    if ($q->param('loc') eq "on the coast"){
        my $xbase=0;
        my $ybase=0;
        my $xcur=0;
        my $ycur=0;
        my $length=0;
        my $totaldistance=$width;
        if ($side eq 'north'){
            $ybase=30;
            $totaldistance=$width;
            $poly->addPt(0,$ybase*2);
        }elsif ($side eq 'south'){
            $ybase=$height-30;
            $totaldistance=$width;
            $poly->addPt(0,$ybase);
        }elsif ($side eq 'east'){
            $xbase=$width-30;
            $totaldistance=$height;
            $poly->addPt($xbase,0);
        }elsif ($side eq 'west'){
            $xbase=30;
            $totaldistance=$height;
            $poly->addPt($xbase,0);
        }
        while ($length < $totaldistance){

            my $lengthmod=  &d(20)-5;
            my $depthmod=   &d(20)-10;
            if ($side eq 'north'){
                $xcur+=$lengthmod;
                $ycur+=$depthmod;
                $ycur=max( $ycur, $ybase);
                $xcur=max( 0, $xcur);
                $length+=$lengthmod;

            }elsif ($side eq 'south'){
                $xcur+=$lengthmod;
                $ycur+=$depthmod;
                $xcur=max( 0, $xcur);
                $ycur=min( $ybase, $ycur);
                $length+=$lengthmod;

            }elsif ($side eq 'east'){
                $xcur+=$depthmod;
                $ycur+=$lengthmod;
                $xcur=min( 0, $xcur);
                $ycur=max( $ybase, $ycur);
                $length+=$lengthmod;

            }elsif ($side eq 'west'){
                $xcur+=$depthmod;
                $ycur+=$lengthmod;
                $xcur=max( 0, $xcur);
                $ycur=max( $ybase, $ycur);
                $length+=$lengthmod;

            }
            if (defined $q->param('debug')  ){
                print(" width: ".($xbase+$xcur)."  height: ".($ybase+$ycur)."\n");
            }
            $poly->addPt($xbase+$xcur,$ybase+$ycur);
        }
        
    }
    if ($side eq 'north'){
        $poly->addPt($width,$height);
        $poly->addPt(0,$height);
    }elsif ($side eq 'south'){
        $poly->addPt($width,0);
        $poly->addPt(0,0);
    }elsif ($side eq 'east'){
        $poly->addPt(0,$height);
        $poly->addPt(0,0);
    }elsif ($side eq 'west'){
        $poly->addPt($width,$height);
        $poly->addPt($width,0);
    }
    
  $img->filledPolygon($poly,$palette->{'grass'});

}


sub draw_ocean(){
    $img->filledRectangle( 0, 0, $width, $height, $palette->{'ocean'} );
}

sub finish {
    # make sure we are writing to a binary stream
    $img->interlaced( 'true' );
    binmode STDOUT;
    print $q->header( 'image/png' );
    # Convert the image to PNG and print it on standard output
    print $img->png;
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
    if (defined $q->param('cityid') and  $q->param('cityid')=~/(\d+)/){
        return $1;
    }else{
        return int rand(1000000);
    }
}


###############################################################################
#
# rand_from_array - select a random item from an array.
#
###############################################################################
sub rand_from_array {
    my ($array) = @_;
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
        return int( rand($die) );
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


